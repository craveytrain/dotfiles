---
name: review-loop
description: Automates the adversarial planner/reviewer review loop. Use after /gsd:new-project completes (with "project-init") or after architecture phase plan is created (with "architecture"). Invoke with /review-loop <checkpoint-type>.
allowed-tools: Read, Write, Bash, Task, Glob, Grep
---

# Adversarial Review Loop Orchestrator

Run the full reviewer/planner refinement loop automatically, spawning isolated sub-agents for each role.

**Checkpoint type:** $ARGUMENTS

## Current State

- Review history exists: !`test -f review-history.md && echo "yes (resumable)" || echo "no (fresh start)"`
- Existing findings: !`ls review-findings-r*.md 2>/dev/null || echo "none"`

## Process

### Step 0: Parse and Validate

Parse the checkpoint type from `$ARGUMENTS`. Valid values:

| Checkpoint | Review Targets | When |
|-----------|---------------|------|
| `project-init` | `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md` | After `/gsd:new-project` |
| `architecture` | `.planning/phases/*/PLAN.md`, `.planning/REQUIREMENTS.md` | After Phase 1 plan created |

If checkpoint type is missing or invalid, ask the user with AskUserQuestion:
- Options: "project-init", "architecture"

Validate that the review target files exist on disk. If missing, stop and tell the user what's needed.

Read `.planning/REVIEW-POLICY.md` and extract the focus areas for this checkpoint type. Store them for injection into sub-agent prompts.

### Step 1: Initialize Round State

Check if `review-history.md` exists:
- If yes: parse it to find the last completed round number. Ask the user: "Resume from round {N+1}?" or "Start fresh?"
- If no: set round = 1

If starting fresh, delete any leftover `review-findings-r*.md`, `review-history.md`, and `planning-log.md`.

### Step 2: The Loop

Repeat for rounds 1 through 4:

#### 2a. Read Instruction Files

Read these files and store their contents for injection into sub-agent prompts:
- `~/.claude/skills/review-loop/reviewer-instructions.md`
- `~/.claude/skills/review-loop/planner-instructions.md`
- `~/.claude/skills/review-loop/agent-loop.md`

(Only needs to happen once; reuse across rounds.)

#### 2b. Spawn Reviewer Agent

Spawn via Task with `subagent_type="general-purpose"`. Build the prompt as follows:

```
<role>
You are the Reviewer Agent in an adversarial plan refinement loop.
This is Round {N}.
</role>

<instructions>
{FULL CONTENTS OF ~/.claude/skills/review-loop/reviewer-instructions.md}
</instructions>

<conventions>
{FULL CONTENTS OF ~/.claude/skills/review-loop/agent-loop.md}
</conventions>

<review_targets>
Read and review these files:
{List of target files for this checkpoint type}
</review_targets>

<focus_areas>
{Focus areas extracted from REVIEW-POLICY.md}
</focus_areas>

<prior_state>
{If round > 1:}
Read these files for context on prior rounds:
- planning-log.md
- review-history.md
- review-findings-r{N-1}.md (for Prior Findings Status section)
{If round == 1:}
This is the first round. No prior findings exist.
planning-log.md may not exist yet. That is expected.
</prior_state>

<user_context>
{If the user answered questions in a previous round, include those Q&A pairs here.}
</user_context>

<output>
You MUST create these files:
1. review-findings-r{N}.md — structured findings (Critical/Significant/Minor/Prior Findings Status/Least Confidence Statement)
2. Append a Round {N} section to review-history.md

Do NOT modify any plan artifact files. You observe and report only.
</output>
```

#### 2c. Read and Parse Findings

After the reviewer agent completes, read `review-findings-r{N}.md` and parse:
- Count of Critical findings (lines under `### Critical` header)
- Count of Significant findings (lines under `### Significant` header)
- Count of Minor findings (lines under `### Minor` header)
- The least-confidence statement (text after `**What am I least confident about`)

Also read the reviewer's addition to `review-history.md` for their confidence level.

#### 2d. Check Termination

The loop should end if ANY of these are true:
1. **Round 4 reached** — hard stop regardless of findings
2. **Clean review (round >= 2)** — zero Critical findings AND zero Significant findings AND least-confidence statement raises nothing material

If terminating, skip to Step 3.

#### 2e. Surface Findings Summary

Present a brief summary to the user:

```
## Round {N} Review Complete

**Critical:** {count} | **Significant:** {count} | **Minor:** {count}

{Bullet list of Critical finding titles}
{Bullet list of Significant finding titles}

**Reviewer's least confidence:** {extracted statement}
```

Then ask the user via AskUserQuestion:
- "Continue to planner round to address findings"
- "Stop the loop here, findings are acceptable"
- "Show me the full findings before deciding"

If user chooses "Show me the full findings", read and display `review-findings-r{N}.md`, then re-ask Continue/Stop.
If user chooses "Stop", skip to Step 3.

#### 2f. Spawn Planner Agent

Spawn via Task with `subagent_type="general-purpose"`. Build the prompt as follows:

```
<role>
You are the Planning Agent in an adversarial plan refinement loop.
This is Round {N}. The reviewer has just completed their assessment.
</role>

<instructions>
{FULL CONTENTS OF ~/.claude/skills/review-loop/planner-instructions.md}
</instructions>

<conventions>
{FULL CONTENTS OF ~/.claude/skills/review-loop/agent-loop.md}
</conventions>

<plan_artifacts>
Read and update these files:
{List of target files for this checkpoint type}
</plan_artifacts>

<review_findings>
Read the reviewer's findings and address each one:
- review-findings-r{N}.md (this round's findings)
- review-history.md (full history for context)
{If N > 1:}
- planning-log.md (your prior round responses, continue appending)
</review_findings>

<user_context>
{If user answered questions, include Q&A pairs here.}
</user_context>

<output>
You MUST:
1. Update plan artifact files to address findings
2. Append a Round {N} section to planning-log.md documenting:
   - What you changed and why
   - Your decision for each finding (fixed / partially addressed / rejected with rationale)
   - Any new uncertainties your changes introduced
   - Any questions needing user input (prefix each with "QUESTION:")
</output>
```

#### 2g. Check for Planner Questions

After the planner agent completes, read `planning-log.md` and scan the Round {N} section for lines starting with `QUESTION:`.

If questions found:
- Present each to the user via AskUserQuestion
- Store the Q&A pairs to inject into the next round's sub-agent prompts

#### 2h. Report and Continue

Display a brief status:

```
## Round {N} Planning Complete

{Summary of changes from planning-log.md}

Proceeding to Round {N+1} review...
```

Increment round number. Continue loop.

### Step 3: Wrap Up

#### 3a. Final Summary

```
## Review Loop Complete

**Checkpoint:** {checkpoint_type}
**Rounds completed:** {N}
**Reason:** {no critical/significant findings | max rounds | user stopped}

**Key improvements made:**
{Bullet summary of major changes across all rounds from planning-log.md}
```

#### 3b. Cleanup

Delete all review process artifacts:
- `review-findings-r*.md` (all rounds)
- `review-history.md`
- `planning-log.md`

Per the agent-loop conventions, the value from these files has been folded into the plan artifacts.

## Important Notes

- **Sub-agent isolation is critical.** Each reviewer and planner agent must be a fresh Task with no shared context. Communication happens only through files on disk.
- **Inject instructions, don't reference them.** Each sub-agent prompt must contain the full text of the relevant instruction files, not just file paths. This guarantees agents follow the protocol.
- **The orchestrator does not modify plan artifacts or review findings.** It only reads files, spawns agents, and interacts with the user.
- **Model selection:** Use opus for both reviewer and planner agents. These are high-stakes foundation reviews.

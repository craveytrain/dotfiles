---
name: verify-scenarios
description: Adversarial scenario evaluation. Reads scenario files from scenarios/, evaluates the running application against them, and writes timestamped results. Read-only, no remediation.
allowed-tools: Read, Bash, Glob, Grep, Write
---

# /verify-scenarios

## Purpose

Adversarial scenario evaluation. You are an independent QA evaluator with no knowledge of implementation decisions, tradeoffs, or intent. You verify what exists against what the scenarios require. Nothing more.

## Rules

1. **Never modify any file** in the repository. Not application code, not scenario files, not test fixtures, not configuration. You are read-only. The only file you create is the results file.
2. **No conditional passes.** A scenario either PASSES or FAILS. If any FAILS IF condition is true, it fails. If SATISFIES is not fully met, it fails.
3. **No interpreting intent.** You don't care what the developer meant to do. You care what the application actually does.
4. **No leniency.** You are not here to be encouraging. You are here to find failures.
5. **Gather real evidence.** Don't reason about whether something "should" work. Run it, query it, navigate to it, inspect it. If you can't produce concrete evidence of a pass, it's a fail.

## Invocation

```
/verify-scenarios
```

Evaluates **all** scenario files in `scenarios/`.

## Procedure

### Step 1: Discover scenarios

Read all `.md` files in `scenarios/`. Parse each scenario block delimited by `---`. Extract:
- The scenario description
- SATISFIES conditions
- FAILS IF conditions

### Step 2: Prepare the environment

- Ensure the application is running. If not, start it using the project's dev server command.
- If scenarios require seed data, check `scenarios/fixtures/` for test data (resumes, JDs, company research). If fixtures exist, use them. If not, note this as a blocker.
- If scenarios require a completed session (e.g., a finished interview with a generated report), create one using the seed data. Drive the application through the full flow to produce the output that needs evaluation.

### Step 3: Evaluate each scenario

For each scenario, determine the appropriate verification method:

**Structural/behavioral scenarios** (UI states, error handling, navigation, loading states):
- Use Playwright MCP or direct HTTP requests to interact with the application
- Take screenshots as evidence
- Assert on DOM content, HTTP responses, visible UI state

**Data/infrastructure scenarios** (database entries, logging, configuration):
- Query the database directly
- Grep the codebase for expected patterns
- Run scripts and inspect output
- Check environment variable wiring

**Content quality scenarios** (feedback quality, specificity, personalization):
- Extract the rendered content from the application
- Compare against the seed data (resume, JD, company research) that produced it
- Judge strictly: does the content reference specific items from the inputs, or is it generic?
- Check for the exact failure patterns described in FAILS IF conditions

### Step 4: Produce results

Write results to `scenarios/results/YYYY-MM-DD-HHmm-results.md` with this format:

```markdown
# Scenario Evaluation Results

**Date:** [timestamp]
**Scenario file(s):** [list of files evaluated]
**Overall:** [X/Y passed]

## Results

### [Scenario file name]

#### Scenario: [description]
**Result:** PASS | FAIL
**Evidence:** [What you checked and what you found. Be specific.]
**Failure reason:** [Only if FAIL — which SATISFIES condition was not met or which FAILS IF condition was triggered. Quote the exact condition.]

---
[repeat for each scenario]

## Summary of Failures

[List only the failures with their scenario descriptions and failure reasons. If no failures, state "All scenarios passed."]
```

### Step 5: Do not remediate

Your job ends at the results file. Do not suggest fixes. Do not open issues. Do not modify code. Report what you found and stop.

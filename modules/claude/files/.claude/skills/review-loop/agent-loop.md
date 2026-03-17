# Agent Loop Shared Conventions

## File Ownership
- The Planner owns all plan artifact files and `planning-log.md`
- The Reviewer owns `review-findings-rN.md` (one per round) and `review-history.md`
- Neither agent modifies the other's files

## Round Numbering
- Rounds start at 1 and increment each time the Reviewer completes a pass
- The round number will be given to you at the start of each session

## Loop Structure
Plan artifacts are created outside this loop (e.g., via GSD planning). The review loop begins after the plan already exists.

1. Reviewer: evaluate plan → write findings and update history → end session
2. Planner: read findings → fix, partially address, or reject each → update plan and planning-log → end session
3. Repeat until termination criteria are met

## Termination
The loop ends at round 4 at the latest, or earlier if the Reviewer finds no Critical or Significant findings and the least-confidence statement raises nothing material. The orchestrator (the human) makes the final call.

## Handoff Clarity
Write your outputs assuming the next agent has no memory of this session. Everything they need to understand what happened must be in the files.

## Cleanup After Termination
When the loop ends (Reviewer recommends stopping and the human confirms), the final agent in the session deletes all review process artifacts:
- `review-findings-r*.md`
- `review-history.md`
- `planning-log.md`

The value from these files has already been folded into the plan artifacts. Don't commit the deletions separately, just remove them.

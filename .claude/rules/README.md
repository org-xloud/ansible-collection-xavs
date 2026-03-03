# .claude/rules/

Rules files in this directory are **auto-loaded into Claude's context** at the start of every session. Use them for detailed knowledge that's too long for a single CLAUDE.md bullet point.

## When to Create a Rules File

- A gotcha needs a code example to explain properly
- A pattern spans multiple files and needs a walkthrough
- An API quirk requires detailed request/response documentation
- A deployment procedure has multiple steps with edge cases

## Format

- One topic per file
- Filename: `<topic-slug>.md` (e.g., `deployment-quirks.md`, `api-version-gotchas.md`)
- Keep files focused — under 50 lines is ideal
- Reference the CLAUDE.md section that links to this file

## How They Get Created

1. **Manually**: Create a file here when you discover something worth documenting
2. **Via `/learn`**: The learn skill creates rules files when a learning is too detailed for CLAUDE.md
3. **Via `doc-learner` agent**: The agent creates rules files during post-session documentation

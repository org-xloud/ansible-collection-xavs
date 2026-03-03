#!/bin/bash
# Auto-learn hook — fires on UserPromptSubmit (before Claude responds)
# Reminds Claude to check for undocumented learnings from the conversation so far

INPUT=$(cat)

cat <<'EOF'
{
  "additionalContext": "AUTO-LEARN: Before responding, quickly consider — has this conversation uncovered any new gotchas, patterns, or fixes that are NOT already documented? If yes, silently update the right file using the Edit tool: (1) CLAUDE.md — append one-line entries to Critical Gotchas, Key Patterns, Anti-Patterns, Build / Test / Deploy, or Task Recipes. (2) .claude/skills/*/SKILL.md — if the learning is specific to a skill's workflow (e.g., a new gotcha when adding a panel, a missing step in deployment), append it to that skill's Common Gotchas section. If nothing new was learned, just proceed normally. Never mention this check to the user."
}
EOF

exit 0

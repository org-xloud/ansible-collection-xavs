---
name: learn
description: Capture a learning, gotcha, or pattern and save it to project docs
user_invocable: true
---

# Capture Learning

You've been asked to capture something learned during this session. Follow this process exactly.

## Step 1: Determine What Was Learned

If the user provided a specific learning, use that. Otherwise, review the recent conversation context and identify:
- Errors encountered and how they were resolved
- Unexpected behavior or API quirks
- Patterns that worked well
- Commands or workflows that were non-obvious
- Architecture decisions and their rationale

## Step 2: Categorize

Classify the learning as one of:

| Category | CLAUDE.md Section | Example |
|----------|-------------------|---------|
| **gotcha** | Critical Gotchas | "Nova returns 500 with JSON body when DIMM hotplug fails on Windows guests" |
| **pattern** | Key Patterns | "Always use `_extract_specs_from_flavor_obj()` — never access `extra_specs` directly" |
| **command** | Build / Test / Deploy | "Run `tox -e py312 -- -k test_name` for single test" |
| **architecture** | Architecture & Dependencies | "Compliance middleware must be after HorizonMiddleware in MIDDLEWARE tuple" |
| **anti-pattern** | Anti-Patterns | "Don't cache novaclient across requests — tokens expire" |
| **recipe** | Task Recipes | "To add a new admin panel: create panel.py, enabled file, views, urls, templates" |

## Step 3: Check for Duplicates

Read CLAUDE.md and check if this learning is already documented:

```
Read CLAUDE.md
Search for key terms from the learning
```

If already documented, tell the user and skip. If partially documented, update the existing entry instead of adding a duplicate.

## Step 4: Append to CLAUDE.md

Add the learning to the appropriate section. Format rules:
- **One line per learning** — keep it scannable
- **Start with the problem or trigger** — what would someone encounter?
- **End with the fix or rule** — what should they do?
- **No fluff** — CLAUDE.md is context, not documentation

Example formats:
```
- `xloud_constants.py` must be manually synced between Nova and Horizon repos — they are NOT auto-synced
- Container restart required for Python changes; template-only changes need just `collectstatic`
- `raise_exc=False` on keystoneauth session calls prevents exceptions on HTTP errors — required for custom error parsing
```

## Step 5: Cross-Repo Impact

If the learning affects other repos, note it clearly:

```
> **Cross-repo**: This also applies to [xloud-nova-2025.1-v2 / watcher-2025.1 / etc.].
> Update that repo's CLAUDE.md too.
```

Repos in the ecosystem:
- `xloud-horizon-2025.1-v2` — Horizon dashboard
- `xloud-nova-2025.1-v2` — Nova compute extensions
- `watcher-2025.1` — Watcher DRS strategy
- `xavs-ansible` — Deployment playbooks
- `xavs-ansible-collection` — Ansible collection

## Step 6: Update Relevant Skills

Check if the learning is specific to a skill's workflow. If so, append it to that skill's **Common Gotchas** section too.

How to decide:
- Learning about panel creation → update `.claude/skills/add-admin-panel/SKILL.md`
- Learning about table actions → update `.claude/skills/add-table-action/SKILL.md`
- Learning about Nova API wrappers → update `.claude/skills/add-nova-api-wrapper/SKILL.md`
- Learning about deployment → update `.claude/skills/deploy-and-test-workflow/SKILL.md`
- Learning about strategies (Watcher) → update `.claude/skills/add-strategy/SKILL.md`
- Learning about Ansible roles → update `.claude/skills/add-service-role/SKILL.md`
- General learning (not skill-specific) → CLAUDE.md only, skip this step

Format for skill gotchas:
```
N. **Short title** — one-line explanation of the gotcha and how to avoid it
```

Only add to skills that already exist. Don't create new skills for a single learning.

## Step 7: Overflow to Rules

If the learning is too detailed for a single CLAUDE.md line (needs code examples, multi-step explanation), create a `.claude/rules/<topic>.md` file instead and add a one-line reference in CLAUDE.md pointing to it.

Rules files are auto-loaded into Claude's context at session start.

## Step 8: Confirm

Tell the user:
- What was added
- Which file(s) were updated (CLAUDE.md, skill, rules)
- Whether other repos need the same update

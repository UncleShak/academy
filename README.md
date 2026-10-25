# The Academy

A Greek-philosopher hierarchy of Claude Code agents. Opus thinks and plans; Sonnet and Haiku do the work. Built to spend as few tokens as possible.

| Agent | Model | Role |
| --- | --- | --- |
| **Plato** | Opus (your main session) | Plans, routes, reviews, decides |
| **Socrates** | Opus | Questions high-stakes changes before they're done |
| **Aristotle** | Sonnet | Builds anything that needs reasoning |
| **Diogenes** | Haiku | Mechanical, fully specified edits |
| **Thales** | Haiku | Read-only search |

You are **the Archon**: you give Plato the goal and have the final say.

## Install

Run in your project folder.

**Windows (PowerShell)**
```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/UncleShak/academy/main/install.ps1)))
```

**macOS, Linux or Git Bash**
```sh
curl -fsSL https://raw.githubusercontent.com/UncleShak/academy/main/install.sh | bash
```

**Or ask Claude Code:** "Run the Academy installer from github.com/UncleShak/academy in this project."

For every project at once, install globally instead: add `-Global` after the closing `)` in PowerShell, or use `bash -s -- --global` with curl.

Then start Claude Code as Plato: `claude --model opus`.

## What it installs

- `.claude/agents/` — Socrates, Aristotle, Diogenes and Thales, each pinned to its model.
- `.claude/academy.md` — Plato's rules: routing, the commission format, token rules, escalation.
- An `@.claude/academy.md` line in `CLAUDE.md` (created if missing; also imports `AGENTS.md` if the project has one).
- `.claude/agora.md` added to `.gitignore`. It's the noticeboard where agents leave each other notes.

Re-run the installer to update. It never duplicates lines.

## How it saves tokens

- Agent descriptions are one line, because they load into every session.
- Haiku does all searching and mechanical work; Sonnet only when reasoning is needed; Opus only plans, reviews, and examines high-stakes changes.
- Commissions pass file paths and line ranges, never pasted contents, and include the exact check commands.
- Agents grep before reading, edit in place, run the narrowest test while working, and report in a fixed short format.
- Plato reviews with `git diff --stat` and reads only the hunks that matter.

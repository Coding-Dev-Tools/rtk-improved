---
name: rtk-token-optimizer
description: >-
  Cut LLM token usage on noisy shell output by routing large, low-stakes
  commands (listings, status, logs, dependency installs, test/build runs)
  through RTK — while keeping full fidelity for diffs, structured/JSON output,
  errors you're debugging, and anything you'll parse or edit. Use when running
  shell commands in Command Code that produce big, repetitive output.
license: Apache-2.0
compatibility: >-
  Requires the RTK binary (>= 0.42.0) on PATH. Verify with `rtk --version`.
  Install from https://github.com/rtk-ai/rtk. RTK is optional — run commands
  normally if it isn't installed.
metadata:
  author: Coding-Dev-Tools
  version: "0.2.0"
  homepage: https://github.com/rtk-ai/rtk
allowed-tools: Bash(rtk:*) Bash(git:*) Bash(cargo:*) Bash(ls:*) Bash(cat:*) Bash(grep:*) Bash(find:*) Bash(diff:*) Bash(docker:*) Bash(kubectl:*) Bash(gh:*) Bash(glab:*) Bash(pnpm:*) Bash(npm:*) Bash(pip:*) Bash(bundle:*) Bash(ruff:*) Bash(tsc:*) Bash(eslint:*) Bash(pytest:*) Bash(go:*) Bash(jest:*) Bash(vitest:*) Bash(dotnet:*) Bash(aws:*) Bash(psql:*) Bash(prisma:*) Bash(wget:*)
---

# RTK Token Optimizer for Command Code

## What it is

[RTK](https://github.com/rtk-ai/rtk) (Rust Token Killer) is a single Rust binary
that filters **shell command output** before it reaches the context window —
dropping noise (progress bars, passing tests, decorative formatting, repeated log
lines) while keeping signal (errors, stack traces, diff hunks, exit codes). When
it can't parse a command's output it falls back to the full raw text, so it never
silently eats data. Typical savings are 60–90% on noisy commands, at <10 ms
overhead.

Done right this is a **double win**: fewer tokens *and* a leaner context, which
measurably improves model reasoning — every frontier model degrades as irrelevant
context grows ("context rot" / "lost in the middle"). Done wrong —
over-compressing output you actually needed — it hides detail and triggers
re-runs that cost more than they saved. The rest of this skill is how to stay on
the winning side.

## Install — two ways

### 1. Auto-rewrite hook (best where supported)

A `PreToolUse` hook rewrites Bash commands to their `rtk` equivalents
automatically, so you never prefix by hand and nothing gets forgotten:

```bash
rtk init -g          # installs the PreToolUse rewrite hook, then restart the agent
```

**Caveat for Command Code:** `rtk init`'s agent list is Claude Code, Copilot,
Cursor, Gemini, Cline, and more — it does **not** include Command Code yet, so
`rtk init -g` wires up Claude Code/Copilot, not Command Code. Command Code does
support `PreToolUse` hooks, so you can register one yourself that pipes the Bash
command through RTK's rewrite (see the Command Code hooks docs and `rtk init
--help`). Until Command Code is supported upstream, Method 2 is the reliable path.
With a hook installed you **run normal commands** and only need the fidelity rules
below to *bypass* compression.

### 2. Manual prefixing (no hook)

Without a hook, prefix commands yourself per the tiers in
[references/commands.md](references/commands.md). Reliable, but you have to
remember it — and `|` pipes and `<<` heredocs bypass the rewrite.

## Decision rule: compress noise, preserve signal

- 🟢 **Compress freely** — large, noisy, low-stakes output you skim:
  `rtk ls`, `rtk git status`, `rtk git log`, `rtk docker ps`, `rtk pip list`.
- 🟡 **Default mode only** — big runs where you need the failures: `rtk cargo
  test`, `rtk err <cmd>`. Plain `rtk` keeps errors/diffs — don't add `-u`.
- 🔴 **Keep full fidelity (run raw)** — diffs/patches you'll apply, JSON or
  `--format` output you'll parse, secrets, small outputs, and files you'll edit
  (use the native Read tool).

Full tiered table: [references/commands.md](references/commands.md).

## Fidelity ladder

Use the *least* compression that still answers the question:

```
raw / native Read  →  rtk <cmd> (keeps signal, default)  →  -u / -l aggressive / rtk smart (lossy, skim-only)
```

Start as far left as the task needs. Escalate compression only for big, boring
output; escalate *fidelity* (drop back to raw or `rtk proxy <cmd>`) the moment a
compressed view is missing something — once, deliberately, not by re-running
blindly.

## When NOT to use RTK

- Diffs/patches you'll apply, JSON/`--format` you'll parse, secrets, small
  outputs — run raw.
- Files you'll edit — use the native Read tool (lossless; bypasses RTK anyway).
- It filters command output, not conversation messages; `|` and `<<` bypass the
  hook.

## Measure net savings

`rtk gain` shows gross savings; `rtk discover` finds good new targets (and
low-savings outliers worth dropping); on failure RTK's tee fallback keeps the
full output. Optimize **net** tokens (savings minus re-runs), not the headline
number. Full reference:
[references/analytics.md](references/analytics.md).

## Prerequisite

RTK on PATH (`rtk --version`). If missing:

- **macOS:** `brew install rtk`
- **Linux/macOS:** `curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh`
- **Windows:** download `rtk-x86_64-pc-windows-msvc.zip` from the [releases page](https://github.com/rtk-ai/rtk/releases) and put `rtk.exe` on PATH.

RTK is optional; never block work to install it.

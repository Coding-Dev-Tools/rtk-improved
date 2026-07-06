---
name: rtk-token-optimizer
description: >-
  Cut LLM token usage on noisy shell output by routing large, low-stakes
  commands (listings, status, logs, dependency installs, test/build runs)
  through RTK — while keeping full fidelity for diffs, structured/JSON output,
  errors you're debugging, and anything you'll parse or edit. Universal
  integration for Command Code, Claude Code, Copilot, Cursor, Gemini, Codex,
  Cline, Windsurf, Kilo Code, Antigravity, OpenCode, Hermes, and Pi.
license: Apache-2.0
compatibility: >-
  Requires the RTK binary (>= 0.42.0) on PATH. Verify with `rtk --version`.
  Install from https://github.com/rtk-ai/rtk. RTK is optional — run commands
  normally if it isn't installed.
metadata:
  author: Coding-Dev-Tools
  version: "2.0.0"
  homepage: https://github.com/Coding-Dev-Tools/rtk-improved
allowed-tools: Bash(rtk:*) Bash(git:*) Bash(cargo:*) Bash(ls:*) Bash(cat:*) Bash(grep:*) Bash(find:*) Bash(diff:*) Bash(docker:*) Bash(kubectl:*) Bash(gh:*) Bash(glab:*) Bash(pnpm:*) Bash(npm:*) Bash(pip:*) Bash(bundle:*) Bash(ruff:*) Bash(tsc:*) Bash(eslint:*) Bash(pytest:*) Bash(go:*) Bash(jest:*) Bash(vitest:*) Bash(dotnet:*) Bash(aws:*) Bash(psql:*) Bash(prisma:*) Bash(wget:*)
---

# RTK Token Optimizer — Universal Agent Integration

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
re-runs that cost more than they saved.

This integration supports **13 AI coding agents** with a unified selective,
signal-preserving policy.

## Supported Agents

| Agent | Integration Type | `rtk init` flag |
|-------|-----------------|-----------------|
| Command Code CLI | AGENTS.md + references | `--command-code` |
| Claude Code | PreToolUse hook | default |
| GitHub Copilot | PreToolUse hook | `--copilot` |
| Cursor | PreToolUse hook | `--agent cursor` |
| Gemini CLI | BeforeTool hook | `--gemini` |
| Codex CLI | AGENTS.md + RTK.md | `--codex` |
| Cline / Roo Code | .clinerules | `--agent cline` |
| Windsurf | .windsurfrules | `--agent windsurf` |
| Kilo Code | Rules file | `--agent kilocode` |
| Google Antigravity | Rules file | `--agent antigravity` |
| OpenCode | TypeScript plugin | `--opencode` |
| Hermes | Python plugin | `--agent hermes` |
| Pi | TypeScript extension | `--agent pi` |

## Decision rule: compress noise, preserve signal

- 🟢 **Compress freely** — large, noisy, low-stakes output you skim:
  `rtk ls`, `rtk git status`, `rtk git log`, `rtk docker ps`, `rtk pip list`.
- 🟡 **Default mode only** — big runs where you need the failures: `rtk cargo
  test`, `rtk err <cmd>`. Plain `rtk` keeps errors/diffs — don't add `--ultra-compact`.
- 🔴 **Keep full fidelity (run raw)** — diffs/patches you'll apply, JSON or
  `--format` output you'll parse, secrets, small outputs, and files you'll edit
  (use the native Read tool).

Full tiered table: [references/commands.md](references/commands.md).

## Fidelity ladder

Use the *least* compression that still answers the question:

```
raw / native Read  →  rtk <cmd> (keeps signal, default)  →  --ultra-compact / -l aggressive / rtk smart (lossy, skim-only)
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

## Compatibility & limitations

- **Exit codes.** RTK aims to pass the wrapped command's exit code through, but it
  isn't guaranteed for every command/version. When a pass/fail verdict matters
  (tests, gates), trust the raw exit code or re-run raw / `rtk proxy <cmd>`.
- **Piped output can be silently wrong, not just decorated.** On a non-TTY pipe
  RTK can substitute its compressed summary for the real content — e.g. a
  redirected `grep` writing a line *count* summary instead of the matching lines
  ([RTK #1282](https://github.com/rtk-ai/rtk/issues/1282), a correctness bug).
  Run anything you'll parse or redirect **raw**. Separately, RTK has emitted ANSI
  color codes into piped/non-TTY output before
  ([RTK #1409](https://github.com/rtk-ai/rtk/issues/1409), fixed); set
  `NO_COLOR=1` defensively if you see escape codes leak through.
- **`-u` is not a working flag.** RTK's own README still lists `-u` as a short
  form of `--ultra-compact`, but it was removed upstream (it collided with
  `git push -u`) and isn't restored — using it fails outright
  ([RTK #2369](https://github.com/rtk-ai/rtk/issues/2369), open). Use the long
  form `--ultra-compact`.
- **Streaming.** RTK buffers to filter, so don't wrap `-f`/follow or growing logs.
- **PATH.** In a non-interactive shell `rtk` may not be found; the integration
  treats it as optional and falls back to raw commands.
- **Native tools.** Your agent's built-in file/search tools are lossless, give
  line numbers, and don't pass through RTK — prefer them over `rtk read/grep/find`.
- **Permissions.** `rtk` (and `rtk proxy`) can execute arbitrary wrapped commands
  — allow-list it deliberately.
- **Hooks on Windows.** RTK's filters work on Windows, but its auto-rewrite hook
  has gaps there ([RTK discussion #671](https://github.com/rtk-ai/rtk/discussions/671)).

## Prerequisite

RTK on PATH (`rtk --version`). If missing:

- **macOS:** `brew install rtk`
- **Linux/macOS:** `curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh`
- **Windows:** download `rtk-x86_64-pc-windows-msvc.zip` from the [releases page](https://github.com/rtk-ai/rtk/releases) and put `rtk.exe` on PATH.

RTK is optional; never block work to install it.

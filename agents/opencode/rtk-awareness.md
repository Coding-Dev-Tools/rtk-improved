# RTK Token Optimization for OpenCode

RTK (Rust Token Killer) compresses **shell command output** before it enters the
context window. Used well it cuts tokens on noisy commands *and* sharpens context
(less noise → better reasoning). Used badly — compressing output you actually
needed — it hides detail and forces re-runs that cost *more* than they save.
These rules keep it net-positive.

## Plugin transparency

You have an RTK TypeScript plugin (`rtk.ts`) that intercepts `tool.execute.before`
and rewrites bash/shell commands through `rtk` automatically. This is a
convenience, not a mandate — it saves you from remembering to prefix every
command. You control when fidelity matters: use the decision rule below.

## The one rule: compress noise, preserve signal

Use `rtk <cmd>` when output is **large, repetitive, low-stakes** — skim, not
study: `rtk ls`, `rtk git status`, `rtk git log`, `rtk docker ps`,
`rtk pip list`, and big test/build runs (`rtk cargo test`, or `rtk err <cmd>` —
RTK keeps the failures and drops the green).

Run the command **raw (no `rtk`)** when you need every character:

- a **diff/patch you'll apply**, or a hunk you'll edit — exact bytes and line
  numbers matter
- **structured output you'll parse** — JSON, `--format=…`, anything piped into
  another tool
- **small output** (≲30 lines) — nothing to save, and real risk of dropping the
  one line you need
- **secrets / exact config** — never reason about a lossy view of these
- a file you intend to **edit** — use the native Read tool (lossless; it bypasses
  RTK anyway)

When unsure, start raw. Lean context comes from cutting *noise*, not *signal*.

## Never default to lossy modes

Plain `rtk <cmd>` keeps the signal — errors, diffs, stack traces, exit codes —
and strips only noise. `--ultra-compact`, `rtk read … -l aggressive`, and
`rtk smart` (2-line summary) are **lossy** — opt-in only for skimming something
huge and unimportant, never your default. (RTK's own docs still mention a `-u`
short form for `--ultra-compact`; it was removed upstream and doesn't work — use
the long flag.)

## Harness safety — don't let it break the tool call

- **Don't wrap streaming/follow output** (`-f`, `tail -f`, a growing log): RTK
  buffers output to filter it, so it can hang the command. Run these raw.
- **When a pass/fail verdict matters** (tests, CI gates), trust the command's raw
  exit code. If you can't tell whether the `rtk` view preserved it, re-run raw or
  use `rtk proxy <cmd>`.
- **Prefer the native file/search tools** over `rtk ls/grep/find/read` — they're
  lossless, give line numbers, and don't pass through RTK anyway.

## If a compressed view isn't enough

On failure, RTK's tee fallback already kept the full output. Otherwise don't
guess or thrash: re-run that one command raw (or `rtk proxy <cmd>`) to see
everything, then move on. One deliberate re-run is fine; blind repeated re-runs
erase the savings.

# RTK — Rust Token Killer (Cline / Roo Code)

**Usage**: Token-optimized CLI proxy (60-90% savings on dev operations).

## Decision rule: compress noise, preserve signal

Use `rtk <cmd>` when output is **large, repetitive, low-stakes** — skim, not
study. Run the command **raw (no `rtk`)** when you need every character.

### 🔴 Keep full fidelity — run raw
- **Diff/patch you'll apply**: `git diff`, `git show` raw — exact bytes matter
- **Structured output you'll parse**: JSON, `--format`, anything piped — compression can corrupt structure
- **Small output** (<30 lines): nothing to save, real risk of dropping the one line you need
- **Secrets / exact config**: never reason about a lossy view
- **Files to edit**: use the native Read tool (lossless; bypasses RTK anyway)
- **Streaming/follow** (`-f`, `tail -f`): RTK buffers, can hang — run raw

### 🟡 Default mode only (plain `rtk`, never `--ultra-compact`)
- `rtk cargo test`, `rtk pytest`, `rtk go test`, `rtk jest`, `rtk vitest` — keeps failures, drops passes
- `rtk cargo build`, `rtk tsc`, `rtk eslint`, `rtk ruff check` — keeps diagnostics, drops progress
- `rtk err <cmd>` — errors-only filter

### 🟢 Compress freely (skim-only)
- `rtk ls`, `rtk git status`, `rtk git log`, `rtk docker ps`, `rtk docker images`
- `rtk kubectl get pods`, `rtk pip list`, `rtk pnpm list`
- `rtk cat app.log` (static triage — NOT with `-f`/follow)

When unsure, start raw. One deliberate re-run is fine; blind repeated re-runs
erase the savings.

## Never default to lossy modes
Plain `rtk <cmd>` keeps the signal — errors, diffs, stack traces, exit codes —
and strips only noise. `--ultra-compact`, `rtk read … -l aggressive`, and
`rtk smart` are **lossy** — opt-in only for skimming something huge and
unimportant. (`-u` was removed upstream, use `--ultra-compact`.)

## Harness safety
- **Don't wrap streaming/follow** (`-f`, `tail -f`, growing log) — RTK buffers
- **Exit codes**: trust the raw exit code for pass/fail verdicts; if unsure, re-run raw or `rtk proxy`
- **Piped output**: RTK can substitute its summary for real content (RTK #1282, #1409) — run anything you'll parse or redirect raw
- **Native tools**: prefer built-in file/search tools over `rtk read/grep/find`

## Meta Commands

```bash
rtk gain              # Token savings analytics
rtk gain --history    # Command usage history with savings
rtk discover          # Find missed opportunities (and poor fits to drop)
rtk proxy <cmd>       # Run raw command without filtering
```

## Verification

```bash
rtk --version
rtk gain
```

# RTK Token Optimization for Command Code

RTK (Rust Token Killer) compresses **shell command output** before it enters the
context window. Used well it cuts tokens on noisy commands *and* sharpens context
(less noise → better reasoning). Used badly — compressing output you actually
needed — it hides detail and forces re-runs that cost *more* than they save.
These rules keep it net-positive.

## Setup

RTK is optional. If `rtk --version` fails, run commands normally — never block
work to install it. Best setup: install RTK's auto-rewrite hook once with
`rtk init -g` (then restart Command Code) so Bash commands are rewritten to `rtk`
automatically and you never prefix by hand. Without a hook, prefix manually per
the tiers in @references/commands.md.

## The one rule: compress noise, preserve signal

Use `rtk <cmd>` when output is **large, repetitive, low-stakes** — skim, not
study: `rtk ls`, `rtk git status`, `rtk git log`, `rtk docker ps`,
`rtk pip list`, and big test/build runs (`rtk cargo test`, or `rtk err <cmd>` —
RTK keeps the failures and drops the green).

Run the command **raw (no `rtk`)** when you need every character:

- a **diff/patch you'll apply**, or a hunk you'll edit — exact bytes and line numbers matter
- **structured output you'll parse** — JSON, `--format=…`, anything piped into another tool
- **small output** (≲30 lines) — nothing to save, and real risk of dropping the one line you need
- **secrets / exact config** — never reason about a lossy view of these
- a file you intend to **edit** — use the native Read tool (lossless; it bypasses RTK anyway)

When unsure, start raw. Lean context comes from cutting *noise*, not *signal*.

## Never default to lossy modes

Plain `rtk <cmd>` keeps the signal — errors, diffs, stack traces, exit codes —
and strips only noise. `-u` / `--ultra-compact`, `rtk read … -l aggressive`, and `rtk smart`
(2-line summary) are **lossy** — opt-in only for skimming something huge and
unimportant, never your default.

## If a compressed view isn't enough

On failure, RTK's tee fallback already kept the full output. Otherwise don't
guess or thrash: re-run that one command raw (or `rtk proxy <cmd>`) to see
everything, then move on. One deliberate re-run is fine; blind repeated re-runs
erase the savings.

@references/commands.md

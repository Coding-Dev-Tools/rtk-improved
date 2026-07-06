# RTK Token Optimization for Pi

RTK compresses **shell command output** before it enters context. Wrap noisy,
low-stakes output to save tokens; run raw when you need every character. Cutting
*noise* helps reasoning; cutting *signal* forces re-runs that cost more than they
save.

## Running raw when the extension auto-wraps

Your `rtk.ts` extension rewrites bash `tool_call`s through `rtk` automatically, so
simply omitting `rtk` does **not** guarantee raw output. To force full fidelity:

- **Files** — use the native Read tool. Lossless, gives line numbers, bypasses RTK.
- **A single command** — prefix `RTK_DISABLED=1` (per-invocation kill switch; the
  hook passes the command through unchanged), or use `rtk proxy <cmd>` for raw
  passthrough that still tracks savings.

## Run RAW — protects correctness (do this first when unsure)

- **Diffs/patches you'll apply** or hunks you'll edit — exact bytes and line
  numbers matter.
- **Output you'll parse** — JSON, `--format=…`, anything piped into another tool.
- **Small output** (≲30 lines) — nothing to save, real risk of dropping the one
  line you need.
- **Secrets / exact config** — never reason about a lossy view.

When in doubt, run raw. A wrong compressed view can fail the task; a raw view only
costs a few tokens.

## Wrap with `rtk <cmd>` — saves tokens on noise

Large, repetitive, low-stakes output you skim rather than study:

- listings and status: `rtk ls`, `rtk git status`, `rtk git log`
- containers/deps: `rtk docker ps`, `rtk pip list`, `rtk pnpm list`
- big test/build runs: `rtk cargo test`, `rtk pytest`, `rtk cargo build` — plain
  `rtk` keeps the failures and diagnostics, drops the passing/progress noise.

## Guardrails

- **Plain `rtk` only.** Never aggressive/lossy modes (`--ultra-compact`, `rtk
  smart`, `-l aggressive`) — they can drop the failing assertion or the
  `file:line` you need, forcing a re-run.
- **Never wrap streaming/follow** (`-f`, `tail -f`, growing logs): RTK buffers to
  filter and can hang the command. Run these raw.
- **Trust the raw exit code** for a pass/fail verdict that matters (tests, gates).
  If unsure the `rtk` view preserved it, re-run raw or `rtk proxy <cmd>`.
- If a compressed view falls short, re-run that **one** command raw and move on.
  One deliberate re-run is fine; blind repeated re-runs erase the savings.

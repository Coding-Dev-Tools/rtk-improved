# RTK Command Reference — compress noise, preserve signal

RTK applies four filters (smart-filter, group, truncate, dedup) to **command
output**. The skill is knowing *when* that helps. Three tiers:

- 🟢 **Compress freely** — large, noisy, low-stakes output you only skim.
- 🟡 **Default mode only** — worth compressing because it's big, but you need the
  failures: use plain `rtk` (which keeps errors/diffs), never `-u`/aggressive.
- 🔴 **Keep full fidelity** — run raw; compression risks dropping what you need.

Plain `rtk <cmd>` keeps the signal and strips only noise. `-u` / `--ultra-compact`, `rtk read … -l
aggressive`, and `rtk smart` (2-line summary) are lossy — reserve them for
skimming something huge and unimportant.

## 🟢 Compress freely (skim-only output)
| Instead of | Use | Why it's safe |
|---|---|---|
| `ls -la` | `rtk ls` | listings dedup/group cleanly |
| `git status`, `git log -n 20` | `rtk git status`, `rtk git log -n 20` | already summaries |
| `docker ps`, `docker images` | `rtk docker ps`, `rtk docker images` | tabular, repetitive |
| `docker logs <c>`, `kubectl logs <p>` (finite) | `rtk docker logs <c>`, `rtk kubectl logs <p>` | dedups repeated lines — **never** with `-f`/follow |
| `kubectl get pods/services` | `rtk kubectl pods`, `rtk kubectl services` | tabular |
| `pip list`, `pnpm list`, `bundle install` | `rtk pip list`, `rtk pnpm list`, `rtk bundle install` | long dependency dumps |
| `cat app.log` (static triage) | `rtk log app.log` | collapses repeated lines — not for `-f`/follow |
| `env` (scan, non-secret) | `rtk env -f AWS` | filters to a prefix |

## 🟡 Default mode only — keep the failures, drop the green
| Instead of | Use | Note |
|---|---|---|
| `cargo test`, `pytest`, `go test`, `jest`, `vitest` | `rtk cargo test`, `rtk pytest`, `rtk go test`, `rtk jest`, `rtk vitest` | keeps failures + traces, drops passes |
| any command you only want errors from | `rtk err <cmd>` | errors-only filter |
| `cargo build`, `tsc`, `eslint`, `ruff`, `clippy` | `rtk cargo build`, `rtk tsc`, `rtk lint`, `rtk ruff check`, `rtk cargo clippy` | keeps diagnostics, drops progress |

Don't add `-u` / aggressive here — you'd risk dropping the failing assertion or
the `file:line` you need, which forces a re-run that costs more than it saved.

## 🔴 Keep full fidelity — run raw (no `rtk`)
| Situation | Do this | Why |
|---|---|---|
| A diff/patch you'll apply | `git diff`, `git show` **raw** | exact bytes and line numbers matter |
| Output you'll parse (JSON, `--format`) | run raw; use `rtk json file` only to *explore* structure | compression can corrupt structure |
| Small output (≲30 lines) | run raw | nothing to save, real risk |
| Secrets / credentials / exact config | run raw | never reason about a lossy view |
| A file you'll **edit** | native Read tool | lossless + line numbers; bypasses RTK anyway |
| You need everything, just this once | `rtk proxy <cmd>` | passthrough + still tracks savings |

## Harness notes

- **Streaming/follow** (`-f`, `tail -f`, a growing log) → run raw; RTK buffers and can hang.
- **Exit status** → for a pass/fail verdict that matters (tests, gates), trust the
  command's raw exit code; if unsure RTK preserved it, re-run raw or `rtk proxy`.
- **Piped output** → RTK may emit icons/decoration over a non-TTY pipe; for anything
  you'll parse, run raw (set `NO_COLOR=1` if decoration leaks in).
- **Native tools** → prefer the built-in file/search tools over `rtk read/grep/find`.

## Analytics

Measuring real savings — and spotting bad fits before they cost you — lives in
[analytics.md](analytics.md): `rtk gain`, `rtk discover`, and the tee fallback.

> RTK supports 100+ commands. Run `rtk --help` for the full set; the tiers above
> are the decision rule, not an exhaustive list. When a command isn't listed,
> apply the rule: noisy and low-stakes → `rtk`; precise or structured → raw.

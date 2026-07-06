# Benchmarking RTK Improved on the Pi harness

**Goal:** show that `rtk-improved` beats the base Pi harness — same task success,
fewer tokens. Two conditions must *both* hold:

1. **Success rate ≥ base** (within noise). One task lost to a compressed diff or
   JSON blob erases the token savings from dozens of tasks. Correctness first.
2. **Net tokens < base**, where net = noise stripped − the awareness doc's
   standing cost − tokens spent re-running commands a lossy view hid.

## Arms

Run the *same* task suite through each arm. Only one variable changes at a time.

| Arm | RTK extension | Awareness doc | Isolates |
|-----|---------------|---------------|----------|
| **A — base** | off | none | the control: no RTK at all |
| **B — rtk-ai** | on | upstream "compress everything" doc | aggressive default |
| **C — rtk-improved** | on | `agents/pi/rtk-awareness.md` (this repo) | selective policy |
| **D — placebo** | on | filler text, **same token length as C**, no RTK guidance | doc *content* vs. doc *length* |

D is the arm most people skip and the one that tells the truth. If C beats A but
not D, the guidance isn't doing the work — you're only measuring the token cost of
adding text. Optionally add **A′** (RTK off + C-length filler doc) to price the
standing-cost tax on its own.

**C wins only if:** `success(C) ≥ success(A)` **and** `tokens(C) < tokens(A)`
**and** C beats D on the primary metric. Also report C vs. B to show selective
beats always-compress.

## Hold everything else constant

Same across all arms: task set, model + version, temperature/seed, turn cap,
per-task timeout, and a **pinned RTK binary version** (record `rtk --version`).
Commit/tag the repo state used for each arm so runs reproduce. Before running,
confirm the escape hatch the C doc relies on actually works on your RTK build —
`RTK_DISABLED=1 <cmd>` and `rtk proxy <cmd>` should return raw output. If they
don't, C can't opt out of compression and will behave like B regardless of the
doc.

## Metrics (per task, then aggregated per arm)

- **pass/fail** — primary. Report rate + 95% CI; suites of <100 tasks are noisy.
- **total tokens** — prompt + completion. Report **both** cache-adjusted and raw;
  prompt caching makes the standing doc cost look cheaper than it is context-wise.
- **turns / tool calls** — a proxy for thrash.
- **raw re-runs after an `rtk` call** — direct count of "compression hid
  something." A key signal for C vs. B.
- **`rtk gain`** (B and C) — gross tokens RTK claims to have saved. Compare to the
  *actual* token delta vs. A; the gap is re-run + overhead cost.

## Reporting

Per-arm summary table (success, mean tokens, mean turns, re-runs) plus a
per-command savings breakdown from `rtk gain --history` for B and C. Call the test
for C only when both win conditions hold on the aggregate, not on cherry-picked
tasks.

## Pitfalls that flip the result

- **Task mix drives the outcome.** Tasks that apply diffs or parse shell JSON
  punish B (and reward C's selectivity); pure skim/status tasks let B post higher
  raw savings at equal success. Report the mix.
- **Short tasks favor A.** With little noisy output, the doc's standing cost can
  exceed anything RTK saves. RTK's edge grows with task length and command noise —
  weight the suite toward realistic multi-command tasks.
- **Caching skews token accounting.** A cached system-prompt doc is cheap to bill
  but still occupies context. Report uncached tokens too.

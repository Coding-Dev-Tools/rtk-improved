# RTK Analytics — measure *net* savings, not just gross

`rtk gain` reports **gross** tokens saved. The number that actually matters is
**net**: gross savings minus (a) tokens spent re-running commands when a
compressed view hid something, and (b) the standing cost of these instructions in
context. Optimize for net.

| Command | Use it to |
|---|---|
| `rtk gain` | session summary: tokens saved, efficiency |
| `rtk gain --graph` | 30-day savings trend |
| `rtk gain --history` | per-command savings — see where RTK actually pays off |
| `rtk gain --quota` | monthly quota savings estimate |
| `rtk discover` | find *good* new opportunities (don't blanket-apply) |
| `rtk session` | RTK adoption across recent sessions |
| `rtk gain --all --format json` | export for dashboards (run raw if you'll parse it) |

## Reading the signal

- **High `--history` savings on noisy commands** → working as intended; keep
  going.
- **Low or zero savings on a command** (visible in `--history`, or surfaced by
  `rtk discover`) → it's a poor fit; run it raw and stop wrapping it. And when a
  command *fails*, RTK's tee fallback (`[tee] mode = "failures"`) has already
  saved the full output — so you never lose error detail on the cases that
  matter.
- **You re-ran a command raw right after its `rtk` version** → that pair was a
  net *loss*. Note the command type and stop compressing it.
- **`rtk discover`** surfaces high-volume, noisy commands worth wrapping — a far
  better guide than wrapping everything by reflex.

Savings vary by command and output size; let `rtk gain` show your real numbers
rather than assuming the headline 60–90%.

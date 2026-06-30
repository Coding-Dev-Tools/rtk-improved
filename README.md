# RTK for Command Code CLI

[RTK](https://github.com/rtk-ai/rtk) (Rust Token Killer) integration for
[Command Code CLI](https://commandcode.ai) — the coding agent that continuously
learns your coding style.

**Save 60-90% LLM tokens** on the shell commands your agent runs.

## How It Works

Command Code CLI reads `~/.commandcode/AGENTS.md` and injects it into the system
prompt for every session. This repository provides that AGENTS.md file (plus a
loadable skill), teaching Command Code to route **noisy** shell output through
`rtk` while keeping **full fidelity** for output it needs exactly. `rtk init`
doesn't target Command Code yet, so the working default is this memory file — the
agent prefixes commands itself; register a Command Code `PreToolUse` hook and RTK
can rewrite them for you automatically.

```
Without RTK:                                 With RTK:
                                             
git status (2,000 tokens)                    rtk git status (200 tokens)
cargo test (25,000 tokens)                   rtk cargo test (2,500 tokens)
ls -la (800 tokens)                          rtk ls (150 tokens)
```

## When RTK helps — and when to keep full fidelity

RTK only pays off when it removes **noise**. This integration is deliberately
selective:

**Compress (🟢/🟡)** — large, repetitive, low-stakes output you skim: listings,
`git status` / `log`, dependency installs, container/cluster status, and big
test/build runs (plain `rtk` keeps the failures and drops the green).

**Keep full fidelity (🔴)** — run the bare command for diffs/patches you'll apply,
JSON or `--format` output you'll parse, secrets, small outputs, and files you'll
edit (use the agent's native file tools). Compressing these is exactly what makes
a tool like this *cost* tokens — the model loses the detail and re-runs the
command.

Two design choices keep it net-positive:

- **Signal-preserving by default.** Plain `rtk <cmd>` keeps errors, stack traces,
  diff hunks, and exit codes and strips only noise; the lossy modes (`-u` /
  `--ultra-compact`, `-l aggressive`, `rtk smart`) are opt-in for skimming only —
  never the default. If a command fails or RTK can't parse its output, you get the
  full raw text back (tee fallback).
- **Measure net, not gross.** `rtk gain` reports gross savings; the goal is *net*
  — savings minus any re-runs and minus the standing cost of these instructions.
  `rtk discover` shows where RTK fits and where savings run low (see
  [references/analytics.md](references/analytics.md)).

This matters for quality too: every frontier model degrades as irrelevant context
grows ("context rot" / "lost in the middle"), so cutting genuine noise can *help*
reasoning — while over-compressing real signal hurts it. The rules above aim for
the first and avoid the second.

## Installation

### Prerequisites

- [Command Code CLI](https://commandcode.ai) — `npm install -g command-code`
- [RTK](https://github.com/rtk-ai/rtk#installation) — you don't have to install
  this yourself: the installer (Method 2) sets it up automatically if it's
  missing. To do it manually: `brew install rtk` or download from releases.

> **Skill vs. memory — which to use?** A **skill** loads on demand: Command Code
> reads its name and description at startup and pulls in the full instructions
> only when a shell task matches or you invoke it. **AGENTS.md memory** is
> injected into the system prompt on *every* session. For always-on `rtk`
> enforcement, install the memory (Method 2); the skill (Method 1) is the
> quickest install and is enough when you mainly want it during shell-heavy work.

> **Optional — the auto-rewrite hook.** A `PreToolUse` hook can rewrite Bash
> commands to `rtk` automatically so the agent never prefixes by hand. Note that
> RTK's `rtk init` installer doesn't target Command Code yet (`rtk init -g` wires
> up Claude Code/Copilot), so for Command Code you'd register the hook yourself.
> Until then, Method 2 below is the reliable path. See `rtk init --help`.

### Method 1: Skill (quick install, on-demand)

```bash
cmd skills add Coding-Dev-Tools/rtk-command-code
```

This installs the RTK skill. Command Code loads its name and description at
startup and reads the full `SKILL.md` instructions when a shell task matches or
when you invoke it explicitly.

### Method 2: AGENTS.md memory (always-on, recommended)

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/Coding-Dev-Tools/rtk-command-code/main/install.sh | bash

# Windows (PowerShell)
iwr -Uri https://raw.githubusercontent.com/Coding-Dev-Tools/rtk-command-code/main/install.ps1 | iex
```

If `rtk` isn't installed yet, the script installs it for you — via RTK's
official installer on macOS/Linux, or the latest GitHub release on Windows.
Pass `--no-rtk` (or `-NoRtk` on Windows) to install only the instructions.

Or clone and run the installer:

```bash
git clone https://github.com/Coding-Dev-Tools/rtk-command-code.git
cd rtk-command-code
chmod +x install.sh && ./install.sh    # Linux/macOS
.\install.ps1                           # Windows
```

### Method 3: Manual Copy

Copy `AGENTS.md` to `~/.commandcode/AGENTS.md`:

```bash
cp AGENTS.md ~/.commandcode/AGENTS.md
cp references/commands.md ~/.commandcode/references/commands.md
cp references/analytics.md ~/.commandcode/references/analytics.md
```

## What It Teaches the Agent

Once installed, Command Code routes **noisy, low-stakes** commands through RTK and
leaves precise output alone:

| Category | Command | Through RTK? | Est. savings |
|---|---|---|---|
| Status / listings | `rtk git status`, `rtk ls`, `rtk git log` | 🟢 yes | ~80% |
| Logs / containers | `rtk docker ps`, `rtk log app.log` | 🟢 yes | ~80% |
| Dependencies | `rtk pip list`, `rtk pnpm list` | 🟢 yes | ~70% |
| Tests / build | `rtk cargo test`, `rtk err <cmd>` | 🟡 plain mode (keeps failures) | ~90% |
| Diffs you'll apply | `git diff`, `git show` | 🔴 run raw | — |
| JSON / parsed output | `… --format json` | 🔴 run raw | — |
| Files you'll edit | native Read tool | 🔴 not RTK | — |

_Savings are illustrative; actual numbers vary by command and output size. Run
`rtk gain` to measure your own — and `rtk discover` to spot poor fits._

See [references/commands.md](references/commands.md) for the full tiered list and
[references/analytics.md](references/analytics.md) for measuring net savings.

## Verify

```bash
rtk gain                # Check token savings
rtk gain --graph        # Visual savings chart
```

After running a few commands through Command Code, `rtk gain` will show the
accumulated savings. Track **net** savings, not just the headline number:
`rtk discover` finds new high-value targets and low-savings outliers, and RTK's
tee fallback keeps full output whenever a command fails. See
[references/analytics.md](references/analytics.md).

## Files

```
rtk-command-code/
├── SKILL.md               # Skill definition (install via cmd skills add)
├── AGENTS.md              # Always-on memory; @imports the references below
├── references/
│   ├── commands.md        # Canonical RTK command-rewrite reference
│   └── analytics.md       # Canonical rtk gain / discover analytics reference
├── install.sh             # Linux/macOS installer
├── install.ps1            # Windows installer
├── .github/               # CI workflow, issue/PR templates, CODEOWNERS
├── CONTRIBUTING.md        # How to contribute
├── CODE_OF_CONDUCT.md     # Contributor Covenant
├── SECURITY.md            # Vulnerability reporting policy
├── LICENSE                # Apache 2.0
└── README.md              # This file
```

## Upstream

This integration was designed to be submitted as a PR to the
[rtk-ai/rtk](https://github.com/rtk-ai/rtk) repository to add Command Code CLI
as a supported agent.

## License

Apache 2.0 — same as [RTK](https://github.com/rtk-ai/rtk).

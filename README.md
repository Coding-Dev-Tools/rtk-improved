# RTK Improved — Universal Agent Integrations for RTK

[RTK] (Rust Token Killer) integrates with AI
coding agents and "claims" to save 60-90% LLM tokens on shell command output. This repository
provides **selective, signal-preserving awareness docs** for every supported
agent — replacing the old "always prefix everything" approach with a
three-tier fidelity ladder that optimizes for **net savings**, not just gross
token counts.

## The Philosophy: Compress Noise, Preserve Signal

RTK is powerful, but wrapping *everything* is counterproductive. Wrapping a diff
you need to apply, JSON you need to parse, or a streaming log that RTK buffers to
a hang — these cost more tokens in re-runs than they save.

This repository teaches agents **when** to wrap and **when** to run raw:

🔴 **Keep full fidelity** — run raw for diffs, JSON, secrets, small output,
streaming
🟡 **Default mode only** — plain `rtk`, never `--ultra-compact`, for
tests/builds where you need the failures
🟢 **Compress freely** — skim-only output like listings, status, dependency
dumps

## Supported Agents

| Agent | Integration Type | Install |
|-------|-----------------|---------|
| **Command Code CLI** | AGENTS.md + references | `rtk init --command-code` or manual copy |
| **Claude Code** | PreToolUse hook + awareness doc | `rtk init` (default) |
| **GitHub Copilot** | PreToolUse hook + awareness doc | `rtk init --copilot` |
| **Cursor** | PreToolUse hook + awareness doc | `rtk init --agent cursor` |
| **Gemini CLI** | BeforeTool hook + GEMINI.md | `rtk init --gemini` |
| **Codex CLI** | AGENTS.md + RTK.md | `rtk init --codex` |
| **Cline / Roo Code** | .clinerules | `rtk init --agent cline` |
| **Windsurf** | .windsurfrules | `rtk init --agent windsurf` |
| **Kilo Code** | Rules file | `rtk init --agent kilocode` |
| **Google Antigravity** | Rules file | `rtk init --agent antigravity` |
| **OpenCode** | TypeScript plugin + awareness doc | `rtk init --opencode` |
| **Hermes** | Python plugin + awareness doc | `rtk init --agent hermes` |
| **Pi** | TypeScript extension + awareness doc | `rtk init --agent pi` |

## Installation

### Quick install (auto-detect your agent)

```bash
# Linux / macOS
curl -fsSL https://raw.githubusercontent.com/Coding-Dev-Tools/rtk-improved/main/install.sh | bash

# Windows (PowerShell)
iwr -Uri https://raw.githubusercontent.com/Coding-Dev-Tools/rtk-improved/main/install.ps1 | iex
```

The installer detects which AI coding agent you're using and installs the
appropriate files. Pass `--agent <name>` to target a specific agent.

### Manual install

Copy the agent file(s) from `agents/<agent-name>/` to the agent's config
directory:

| Agent | Copy this | To here |
|-------|-----------|---------|
| Command Code | `agents/command-code/AGENTS.md` + `references/` | `~/.commandcode/` |
| Cline | `agents/cline/rules.md` | `.clinerules` (project root) |
| Windsurf | `agents/windsurf/rules.md` | `.windsurfrules` (project root) |
| Codex | `agents/codex/RTK.md` | `~/.codex/RTK.md` |
| (others) | See agent subdirectory README | |

## Files

```
rtk-improved/
├── AGENTS.md                    # Universal selective RTK instructions
├── README.md                    # This file
├── CHANGELOG.md                 # Release history
├── BENCHMARK.md                 # Four-arm test design (base vs. rtk-ai vs. rtk-improved)
├── CONTRIBUTING.md              # How to contribute
├── LICENSE                      # Apache 2.0
├── SKILL.md                     # Universal RTK skill definition
├── install.sh                   # Linux/macOS multi-agent installer
├── install.ps1                  # Windows multi-agent installer
├── agents/                      # Per-agent awareness docs
│   ├── command-code/            # Command Code CLI awareness docs
│   ├── claude-code/             # Claude Code (awareness doc)
│   ├── copilot/                 # GitHub Copilot (awareness doc)
│   ├── cursor/                  # Cursor (awareness doc)
│   ├── gemini/                  # Gemini CLI (GEMINI.md)
│   ├── codex/                   # Codex CLI (RTK.md)
│   ├── cline/                   # Cline / Roo Code (rules.md)
│   ├── windsurf/                # Windsurf (rules.md)
│   ├── kilocode/                # Kilo Code (rules.md)
│   ├── antigravity/             # Google Antigravity (rules.md)
│   ├── opencode/                # OpenCode (awareness doc)
│   ├── hermes/                  # Hermes (awareness doc)
│   └── pi/                      # Pi (awareness doc)
├── references/                  # Shared reference docs
│   ├── commands.md              # Tiered command table
│   └── analytics.md             # Net savings measurement guide
└── .github/                     # CI, templates, CODEOWNERS
```

## Upstream

The awareness docs in this repository are embedded in the `rtk-ai/rtk` Rust
binary via `include_str!` and installed by `rtk init`. This repository is the
canonical source for those docs — edits here flow into the next RTK release.

## License

Apache 2.0 — same as [RTK].

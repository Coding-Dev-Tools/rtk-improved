# Changelog

All notable changes to this integration are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/), and this project aims to adhere
to [Semantic Versioning](https://semver.org).

## [2.1.0] — 2026-07-03

### Added
- `BENCHMARK.md`: four-arm test design (base / rtk-ai / rtk-improved / placebo)
  for verifying that rtk-improved beats the base harness on net tokens without
  losing task success, including controls, metrics, and win conditions
- Pi awareness doc: explicit raw escape hatch (`RTK_DISABLED=1 <cmd>`,
  `rtk proxy <cmd>`, native Read for files) — the agent can now reliably opt out
  when the `rtk.ts` extension auto-wraps a bash call
- CI: agent-doc lint (every doc must keep raw-fidelity guidance and must not
  reintroduce "always prefix everything"); Pi doc must document the escape hatch

### Changed
- Pi awareness doc rewritten to cut standing context cost — the tax RTK must
  overcome to beat baseline. Raw-fidelity (correctness) cases now lead; dropped
  GitHub issue citations, emoji tier markers, and repeated motivational prose;
  aggressive-mode trivia collapsed to one guardrail. Human-facing rationale stays
  in README/CONTRIBUTING.

## [2.0.0] — 2026-07-03

### Added
- Universal multi-agent support: awareness docs for all 13 RTK-supported agents
  (Command Code, Claude Code, Copilot, Cursor, Gemini, Codex, Cline, Windsurf,
  Kilo Code, Antigravity, OpenCode, Hermes, Pi)
- Selective signal-preserving fidelity ladder applied across all agents (replaces
  "always prefix everything" policy from upstream RTK)
- Per-agent awareness docs (rules files, AGENTS.md, GEMINI.MD) with three-tier
  fidelity model: 🟢 compress freely, 🟡 default mode only, 🔴 keep full fidelity
- Shared reference files: `references/commands.md` (tiered command table),
  `references/analytics.md` (net savings measurement)
- Multi-agent installer (`install.sh`, `install.ps1`) with `--agent` targeting
- Hook/plugin agent awareness docs (Cursor, OpenCode, Hermes, Pi, Gemini)
  that teach hook transparency — the hook is a convenience, not a mandate

### Changed
- Repo renamed from `rtk-command-code` to `rtk-improved` to reflect universal scope
- All agent docs upgraded from "always prefix everything" to selective
  signal-preserving policy
- Claude Code awareness doc: added fidelity ladder + hook transparency section
- Copilot awareness doc: condensed hook description, added fidelity ladder
- Rules-file agents (Cline, Windsurf, Kilo Code, Antigravity, Codex): replaced
  33-line "always prefix" template with 60-line selective fidelity ladder

### Fixed
- Gemini: created proper `rtk-awareness.md` file (was generated from generic
  template in `init.rs`)
- All docs now consistently document: `-u` removed upstream (use `--ultra-compact`),
  piped output correctness bugs (RTK #1282, #1409), streaming/follow safety

## [1.0.1] — 2026-06-30

### Fixed
- Removed all references to a `-u` short form of `--ultra-compact`
- Corrected piped-output citation (RTK #1282 is a correctness bug, not ANSI)
- Synced SKILL.md compatibility section with README.md

## [1.0.0] — 2026-06-30

### Added
- Initial release of RTK integration for Command Code CLI
- Selective, signal-preserving policy: compress noise, preserve signal
- Three-tier command reference with fidelity ladder
- Analytics reference for net savings measurement
- Installers for Linux/macOS and Windows
- SKILL.md for on-demand loading, AGENTS.md for always-on memory

[2.1.0]: https://github.com/Coding-Dev-Tools/rtk-improved/releases/tag/v2.1.0
[2.0.0]: https://github.com/Coding-Dev-Tools/rtk-improved/releases/tag/v2.0.0
[1.0.1]: https://github.com/Coding-Dev-Tools/rtk-command-code/releases/tag/v1.0.1
[1.0.0]: https://github.com/Coding-Dev-Tools/rtk-command-code/releases/tag/v1.0.0

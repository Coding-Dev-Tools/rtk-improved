# Contributing to RTK Improved

Thanks for your interest in improving this integration. It provides selective,
signal-preserving awareness docs for all 13 AI coding agents supported by
[RTK](https://github.com/rtk-ai/rtk).

## What's in this repo

This is a documentation-and-installer project — there is no compiled code:

- `agents/<name>/` — per-agent awareness docs (AGENTS.md, rules, GEMINI.md, etc.)
- `references/commands.md` — canonical RTK command-rewrite reference (tiered table)
- `references/analytics.md` — canonical `rtk gain` / `discover` reference
- `install.sh`, `install.ps1` — multi-agent installers for macOS/Linux and Windows
- `SKILL.md` — the on-demand skill definition
- `AGENTS.md` — universal always-on memory

## Ways to contribute

- Add or correct RTK command mappings in `references/commands.md`
- Improve installer reliability or platform coverage
- Add awareness docs for a new agent
- Clarify the fidelity ladder or harness safety guidance
- Update agent docs to reflect RTK changes

## Ground rules

- **Fidelity ladder.** All agent awareness docs must follow the selective
  three-tier model: 🔴 keep full fidelity, 🟡 default mode only, 🟢 compress
  freely. "Always prefix everything" language is deprecated.
- **Line endings.** `.gitattributes` enforces LF everywhere except `*.ps1`
  (CRLF). Never commit CRLF in shell scripts or Markdown — it breaks bash
  shebangs and heredocs. If your editor rewrites endings, run
  `git add --renormalize .` before committing.
- **Keep the skill spec-compliant.** `SKILL.md` must retain its YAML
  frontmatter with `name:` and `description:`. CI validates this.
- **Keep references in sync.** Command rewrites live in
  `references/commands.md`; analytics commands live in
  `references/analytics.md`. Don't duplicate tables across files.

## Adding a new agent

1. Create `agents/<agent-name>/` with the appropriate file(s)
2. Follow the existing format — include the full fidelity ladder, harness
   safety notes, and meta commands section
3. For hook/plugin agents, include a "Hook transparency" section explaining
   that the hook is a convenience, not a mandate
4. Update `README.md` to add the agent to the supported agents table
5. Update `install.sh` and `install.ps1` if the agent has a known install path

## Testing locally

The same checks CI runs:

```bash
bash -n install.sh                    # syntax-check the installer
grep -E '^(name|description):' SKILL.md   # confirm required frontmatter
```

If you touched an installer, run it end to end:

```bash
./install.sh --quiet --no-rtk   # macOS/Linux
.\install.ps1 -Quiet -NoRtk     # Windows
```

## License

By contributing, you agree that your contributions are licensed under the
[Apache License 2.0](LICENSE).

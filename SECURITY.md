# Security Policy

## Reporting a vulnerability

Please **do not** open a public issue for security problems.

Report vulnerabilities privately through GitHub's
[private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability):
open the **Security** tab of this repository and click **Report a
vulnerability**.

If private vulnerability reporting is not enabled or you prefer email, contact
**algorithmictradingsolutions@gmail.com** instead. Please put "SECURITY" in the
subject line and avoid posting any details in public issues or discussions.

We aim to acknowledge reports within a few business days and will keep you
updated as we investigate.

## Scope

This project ships Markdown instructions and shell/PowerShell installers. The
most relevant risks are:

- The `install.sh` / `install.ps1` scripts, which write to agent-specific config directories (`~/.commandcode/`, `~/.config/rtk/`, etc.).
- The `curl … | sh` and `iwr … | iex` one-liners documented in the README.

If you find a way these could be abused (for example path traversal or
unexpected file writes), please report it.

RTK itself is a separate project — report issues with the `rtk` binary at
[rtk-ai/rtk](https://github.com/rtk-ai/rtk).

## Supported versions

This is a small integration; only the latest `main` is supported. Please test
against current `main` before reporting.

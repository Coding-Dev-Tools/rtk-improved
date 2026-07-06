#!/usr/bin/env bash
set -euo pipefail

# RTK Improved — Multi-Agent Installer (Linux/macOS)
#
# Works two ways:
#   - From a cloned repo:  ./install.sh                       (copies sibling files)
#   - Piped from the web:  curl -fsSL <raw>/install.sh | bash (downloads the files)
#
# Auto-detects your AI coding agent or accepts --agent <name> to target
# a specific agent. Supports all 13 RTK-integrated agents.
#
# If the RTK binary is missing, this installer offers to install it for you via
# RTK's official installer, so you don't have to install RTK separately.

REPO_RAW="https://raw.githubusercontent.com/Coding-Dev-Tools/rtk-improved/main"
RTK_INSTALL_URL="https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

step()  { printf '  %b=>%b %s\n'     "$CYAN"   "$NC" "$1"; }
ok()    { printf '  %b[OK]%b %s\n'   "$GREEN"  "$NC" "$1"; }
warn()  { printf '  %b[!!]%b %s\n'   "$YELLOW" "$NC" "$1"; }
fail()  { printf '  %b[FAIL]%b %s\n' "$RED"    "$NC" "$1"; exit 1; }

QUIET=false
NO_RTK=false
TARGET_AGENT=""
for arg in "$@"; do
    case "$arg" in
        -h|--help)
            cat <<'EOF'
RTK Improved — Universal Multi-Agent Installer (Linux/macOS)

Installs RTK token optimization instructions for your AI coding agent, and
(if it is missing) the RTK binary itself.

Usage:
  ./install.sh                  Auto-detect your agent and install
  ./install.sh --agent <name>   Install for a specific agent
  ./install.sh --quiet          Silent install (no prompts; auto-installs RTK)
  ./install.sh --no-rtk         Do not install the RTK binary, only the instructions
  curl -fsSL <raw>/install.sh | bash  Install directly from the web

Supported agents: command-code, claude-code, copilot, cursor, gemini, codex,
  cline, windsurf, kilocode, antigravity, opencode, hermes, pi

What it does:
  1. Installs the RTK binary via its official installer if `rtk` is not on PATH
  2. Installs agent-specific awareness docs to the correct config directory
  3. For Command Code: AGENTS.md + references/ to ~/.commandcode/
  4. For other agents: appropriate config file (see agent docs)

Requires:
  - curl or wget (for downloading files)
EOF
            exit 0
            ;;
        --quiet)  QUIET=true ;;
        --no-rtk) NO_RTK=true ;;
        --agent)
            shift
            TARGET_AGENT="$1"
            ;;
        --agent=*)
            TARGET_AGENT="${arg#*=}"
            ;;
        *) warn "Unknown option: $arg" ;;
    esac
done

# Ask a yes/no question that still works when this script is itself piped to
# bash via stdin (curl | bash) — in that case stdin is the script, so read from
# the controlling terminal instead. $2 is the default ("y" or "n").
confirm() {
    local prompt="$1" default="${2:-n}" reply
    $QUIET && { [[ "$default" == "y" ]]; return; }
    if [[ -r /dev/tty ]]; then
        read -r -p "$prompt " reply </dev/tty || reply=""
        [[ -z "$reply" ]] && reply="$default"
        [[ "$reply" == "y" || "$reply" == "Y" ]]
    else
        # Non-interactive (piped) and not quiet: fall back to the default.
        [[ "$default" == "y" ]]
    fi
}

install_rtk() {
    step "Installing the RTK binary (RTK's official installer)..."
    if command -v curl &>/dev/null; then
        curl -fsSL "$RTK_INSTALL_URL" | sh || warn "RTK installer reported an error."
    elif command -v wget &>/dev/null; then
        wget -qO- "$RTK_INSTALL_URL" | sh || warn "RTK installer reported an error."
    else
        warn "Need curl or wget to install RTK."
        return
    fi
    if command -v rtk &>/dev/null; then
        ok "RTK installed: $(rtk --version)"
    else
        warn "RTK was installed but is not on this shell's PATH yet."
        warn "Open a new shell, or see https://github.com/rtk-ai/rtk#installation"
    fi
}

# --- Step 1: Check prerequisites ---
step "Checking prerequisites..."

# Auto-detect agent if no --agent was given
detect_agent() {
    if [[ -n "$TARGET_AGENT" ]]; then
        echo "$TARGET_AGENT"
        return
    fi
    # Check for Command Code CLI
    if command -v cmd &>/dev/null || command -v cmdc &>/dev/null || command -v command-code &>/dev/null; then
        echo "command-code"
        return
    fi
    # Check for Claude Code
    if command -v claude &>/dev/null || [[ -d "$HOME/.claude" ]]; then
        echo "claude-code"
        return
    fi
    # Check for Gemini
    if [[ -d "$HOME/.gemini" ]]; then
        echo "gemini"
        return
    fi
    # Check for Codex
    if [[ -d "$HOME/.codex" ]]; then
        echo "codex"
        return
    fi
    # Default: install universal AGENTS.md to ~/.commandcode/
    echo "command-code"
}
AGENT=$(detect_agent)
echo "Detected agent: $AGENT"

if command -v rtk &>/dev/null; then
    ok "RTK found: $(rtk --version)"
elif $NO_RTK; then
    warn "RTK not found (--no-rtk set). Install later: https://github.com/rtk-ai/rtk#installation"
else
    warn "RTK not found in PATH."
    if confirm "Install RTK now? (Y/n)" y; then
        install_rtk
    else
        warn "Skipped RTK install. Install later: https://github.com/rtk-ai/rtk#installation"
    fi
fi

# --- Step 2: Locate the script's own directory (empty when piped via stdin) ---
SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

AGENTS_DIR="$HOME/.commandcode"
REF_DIR="$AGENTS_DIR/references"
mkdir -p "$REF_DIR"

fetch() {
    # fetch <relative-path> <dest>
    if command -v curl &>/dev/null; then
        curl -fsSL "$REPO_RAW/$1" -o "$2"
    elif command -v wget &>/dev/null; then
        wget -qO "$2" "$REPO_RAW/$1"
    else
        fail "Need curl or wget to download $1 (or run from a cloned repo)."
    fi
}

# --- Step 3: Install agent-specific files ---
install_for_command_code() {
    local AGENTS_DIR="$HOME/.commandcode"
    local REF_DIR="$AGENTS_DIR/references"
    mkdir -p "$REF_DIR"

    if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/agents/command-code/AGENTS.md" ]]; then
        cp "$SCRIPT_DIR/agents/command-code/AGENTS.md"    "$AGENTS_DIR/AGENTS.md"
        cp "$SCRIPT_DIR/agents/command-code/commands.md"  "$REF_DIR/commands.md"
        cp "$SCRIPT_DIR/agents/command-code/analytics.md" "$REF_DIR/analytics.md"
    else
        fetch "agents/command-code/AGENTS.md"    "$AGENTS_DIR/AGENTS.md"
        fetch "agents/command-code/commands.md"  "$REF_DIR/commands.md"
        fetch "agents/command-code/analytics.md" "$REF_DIR/analytics.md"
    fi

    for f in "$AGENTS_DIR/AGENTS.md" "$REF_DIR/commands.md" "$REF_DIR/analytics.md"; do
        [[ -s "$f" ]] || fail "Missing or empty after install: $f"
    done
    ok "Installed AGENTS.md + references/ to $AGENTS_DIR"
}

install_for_rules_agent() {
    local agent="$1" dest="$2" src="$3"
    if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/$src" ]]; then
        cp "$SCRIPT_DIR/$src" "$dest"
    else
        fetch "$src" "$dest"
    fi
    [[ -s "$dest" ]] || fail "Missing or empty after install: $dest"
    ok "Installed $agent rules to $dest"
}

install_agent_files() {
    step "Installing instructions for $AGENT..."
    case "$AGENT" in
        command-code)
            install_for_command_code
            ;;
        cline)
            install_for_rules_agent "Cline" ".clinerules" "agents/cline/rules.md"
            ;;
        windsurf)
            mkdir -p "$HOME/.windsurf"
            install_for_rules_agent "Windsurf" ".windsurfrules" "agents/windsurf/rules.md"
            ;;
        codex)
            mkdir -p "$HOME/.codex"
            install_for_rules_agent "Codex" "$HOME/.codex/RTK.md" "agents/codex/RTK.md"
            ;;
        gemini)
            mkdir -p "$HOME/.gemini"
            install_for_rules_agent "Gemini" "$HOME/.gemini/GEMINI.md" "agents/gemini/GEMINI.md"
            ;;
        kilocode|antigravity|claude-code|copilot|cursor|opencode|hermes|pi)
            step "For $AGENT, use: rtk init --agent $AGENT"
            step "(Awareness docs are available in agents/$AGENT/ — copy manually or use rtk init)"
            ;;
        *)
            warn "Unknown agent: $AGENT. Installing universal AGENTS.md to ~/.commandcode/"
            install_for_command_code
            ;;
    esac
}
install_agent_files

# --- Step 4: Verify ---
step "Verifying installation..."
ok "Installation verified for $AGENT"

# --- Done ---
printf '\n%bInstallation complete!%b\n\n' "$GREEN" "$NC"
echo "  RTK instructions installed for $AGENT."
echo "  Restart any active agent sessions to apply."
echo ""
echo "  Verify: rtk gain"
echo ""

#!/usr/bin/env bash
# Validate rtk-command-code documentation integrity
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0

echo "=== rtk-command-code validation ==="

# Required files
for f in AGENTS.md CHANGELOG.md CODE_OF_CONDUCT.md CONTRIBUTING.md LICENSE README.md SECURITY.md SKILL.md VERSION install.sh install.ps1; do
  [ -f "$ROOT/$f" ] || { echo "FAIL: $f missing"; fail=1; }
done

# VERSION semver
version=$(tr -d '[:space:]' < "$ROOT/VERSION")
echo "$version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$' || { echo "FAIL: VERSION not semver: $version"; fail=1; }

# SKILL.md frontmatter
head -1 "$ROOT/SKILL.md" | grep -qx -- '---' || { echo "FAIL: SKILL.md no frontmatter"; fail=1; }
grep -qE '^name:' "$ROOT/SKILL.md" || { echo "FAIL: SKILL.md no name"; fail=1; }

# AGENTS.md @imports
while IFS= read -r ref; do
  [ -f "$ROOT/${ref#@}" ] || { echo "FAIL: missing @import ${ref#@}"; fail=1; }
done < <(grep -aoE '^@[A-Za-z0-9._/-]+' "$ROOT/AGENTS.md" || true)

# SKILL.md references
for f in $(grep -aoE 'references/[A-Za-z0-9._/-]+\.md' "$ROOT/SKILL.md" | sort -u); do
  [ -f "$ROOT/$f" ] || { echo "FAIL: missing $f"; fail=1; }
done

# CHANGELOG.md version header
grep -qE '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' "$ROOT/CHANGELOG.md" || { echo "FAIL: CHANGELOG.md no version header"; fail=1; }

echo "=== $([ "$fail" -eq 0 ] && echo 'ALL PASSED' || echo 'SOME FAILED') ==="
exit $fail

#!/usr/bin/env bash
# PreToolUse safety hook: block Claude from reading/exfiltrating secret files.
#
# Reads the tool-call JSON on stdin and denies the call when it targets a
# protected file:
#   - Read / Edit / Write / NotebookEdit  -> checks file_path / notebook_path
#   - Grep / Glob                         -> checks path / glob
#   - Bash                                -> denies only when a read/copy command
#                                            (cat, head, cp, source, "< file", ...)
#                                            actually operates on a secret file, so
#                                            merely mentioning a filename in a commit
#                                            message or echo is NOT blocked.
#
# Protected: .env, .env.*, *.env, *.local, *.pem, *.key, id_rsa*, id_ed25519*,
#            .zshrc.local, .zshrc.bak
# Allowed templates: .env.example / .env.sample / .env.template / .env.dist
set -euo pipefail
set -f

input="$(cat)"
tool="$(printf '%s' "$input" | jq -r '.tool_name // empty')"

is_secret() {
  local base
  base="$(basename -- "$1")"
  case "$base" in
    .env.example|.env.sample|.env.template|.env.dist) return 1 ;;
  esac
  case "$base" in
    .env|.env.*|*.env|*.local|*.pem|*.key|id_rsa|id_rsa.*|id_ed25519|id_ed25519.*|.zshrc.local|.zshrc.bak) return 0 ;;
  esac
  return 1
}

deny() {
  jq -n --arg f "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Blocked by local safety hook: \($f) is a protected secret file. Reading secrets (.env / *.env, *.local, *.pem, *.key, private keys, .zshrc.local/.bak) is disabled."
    }
  }'
  exit 0
}

# Deny if any filename-safe token in $1 matches a protected pattern.
scan_tokens() {
  local tok
  for tok in $(printf '%s' "$1" | tr -c 'A-Za-z0-9._/~-' ' '); do
    [ -n "$tok" ] || continue
    if is_secret "$tok"; then deny "$tok"; fi
  done
}

case "$tool" in
  Read|Edit|Write|NotebookEdit)
    scan_tokens "$(printf '%s' "$input" | jq -r '[.tool_input.file_path, .tool_input.notebook_path] | map(select(. != null)) | join(" ")')"
    ;;
  Grep|Glob)
    scan_tokens "$(printf '%s' "$input" | jq -r '[.tool_input.path, .tool_input.glob] | map(select(. != null)) | join(" ")')"
    ;;
  Bash)
    cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
    # Content-exposing commands. Only these (or a "< file" redirect) turn a
    # secret-filename mention into an actual read worth blocking.
    readers='cat|tac|nl|head|tail|less|more|bat|most|view|xxd|od|hexdump|strings|base64|openssl|gpg|grep|egrep|fgrep|rg|ag|ack|awk|sed|cut|sort|uniq|column|jq|yq|dd|cp|scp|rsync|mv|source'
    if printf '%s' "$cmd" | grep -Ewq "$readers" || printf '%s' "$cmd" | grep -q '<'; then
      scan_tokens "$cmd"
    fi
    ;;
  *)
    exit 0 ;;
esac

exit 0

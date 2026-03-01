#!/usr/bin/env bash
#
# SubagentStop hook — neovim agent
#
# Fires when the neovim subagent ends. Reads the session transcript,
# calls Claude to extract any learnings, and updates neovim.md in place.
#
# Runs async so it never blocks the parent session.

PAYLOAD=$(cat)

# Only run for the neovim agent
[[ "$(echo "$PAYLOAD" | jq -r '.agent_type // ""')" == "neovim" ]] || exit 0

# Loop guard: don't re-run if a stop hook already triggered a continuation
[[ "$(echo "$PAYLOAD" | jq -r '.stop_hook_active')" != "true" ]] || exit 0

# Require API key
[[ -n "${ANTHROPIC_API_KEY:-}" ]] || exit 0

AGENT_FILE="$HOME/github.com/josefaidt/dotfiles/.claude/agents/neovim.md"
[[ -f "$AGENT_FILE" ]] || exit 0

TRANSCRIPT_PATH="$(echo "$PAYLOAD" | jq -r '.agent_transcript_path // ""')"
TRANSCRIPT_PATH="${TRANSCRIPT_PATH/#\~/$HOME}"
[[ -f "$TRANSCRIPT_PATH" ]] || exit 0

CURRENT=$(cat "$AGENT_FILE")
LAST_MSG=$(echo "$PAYLOAD" | jq -r '.last_assistant_message // ""')

# Parse transcript — extract readable entries from last 100 lines
TRANSCRIPT=$(
  tail -100 "$TRANSCRIPT_PATH" | while IFS= read -r line; do
    echo "$line" | jq -r '
      try (
        "[" + (.role // "?") + "]: " + (
          if (.content | type) == "string" then .content[:400]
          else (
            .content // []
            | map(
                if .type == "text" then .text[:400]
                elif .type == "tool_use" then "<tool:\(.name)>"
                else empty
                end
              )
            | join(" | ")
          )
          end
        )
      ) catch ""
    ' 2>/dev/null
  done | grep -v '^$' || true
)

# Write prompt to a temp file to avoid shell quoting issues
PROMPT_FILE=$(mktemp)
trap 'rm -f "$PROMPT_FILE"' EXIT

cat > "$PROMPT_FILE" << HEREDOC
You maintain the definition file for the "neovim" Claude Code subagent. The agent just completed a session. Review the transcript and update the agent file only if there are clear, meaningful learnings.

## Current Agent File
\`\`\`markdown
$CURRENT
\`\`\`

## Session Transcript
$TRANSCRIPT

## Final Response
$LAST_MSG

## Instructions
Update the file to capture any learnings:
- New facts about the config not yet documented (plugins, keymaps, LSP, conventions)
- Corrections to inaccurate information
- Missing context that caused confusion or extra back-and-forth

Rules: only update what is clearly supported by the transcript. Preserve all existing accurate content. Keep the same frontmatter, format, and style. If nothing meaningful to add, return the file unchanged. Return the complete file content only — no explanation, no markdown fences.
HEREDOC

UPDATED=$(
  curl -sf https://api.anthropic.com/v1/messages \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    -d "$(jq -n --rawfile prompt "$PROMPT_FILE" '{
      model: "claude-haiku-4-5-20251001",
      max_tokens: 8192,
      messages: [{ role: "user", content: $prompt }]
    }')" \
  | jq -r '.content[0].text // ""'
)

[[ -n "$UPDATED" && "$UPDATED" != "$CURRENT" ]] || exit 0

printf '%s' "$UPDATED" > "$AGENT_FILE"
echo "[subagent-stop] updated neovim.md with session learnings" >&2

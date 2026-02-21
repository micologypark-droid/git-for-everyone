#!/usr/bin/env bash
# Hook: workflow-guide.sh
# Trigger: PreToolUse (Bash)
# main/master 브랜치에서 commit/merge를 차단하여 GitHub Flow를 안내합니다

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")

if [ -z "$COMMAND" ]; then
  exit 0
fi

# commit/merge 명령어가 아니면 바로 통과
echo "$COMMAND" | grep -qE '\bgit\s+(commit|merge)\b' || exit 0

# 현재 브랜치 확인
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")

# main/master가 아니면 바로 통과
if [[ ! "$CURRENT_BRANCH" =~ ^(main|master)$ ]]; then
  exit 0
fi

block() {
  echo "차단: $1"
  echo "  → $2"
  exit 2
}

# git commit on main/master
if echo "$COMMAND" | grep -qE '\bgit\s+commit\b'; then
  block "$CURRENT_BRANCH 브랜치에서 직접 commit 불가" "feature 브랜치를 만들고 작업하세요: git checkout -b feat/my-feature"
fi

# git merge on main/master
if echo "$COMMAND" | grep -qE '\bgit\s+merge\b'; then
  block "$CURRENT_BRANCH 브랜치에서 직접 merge 불가" "PR을 통해 머지하세요: gh pr merge"
fi

exit 0

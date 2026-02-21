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
  echo "차단: $CURRENT_BRANCH 브랜치에서 직접 commit할 수 없습니다."
  echo ""
  echo "아래 순서대로 진행하세요:"
  echo "  1. 새 브랜치를 만드세요 (변경 사항은 자동으로 유지됩니다):"
  echo "     git checkout -b feat/<작업-설명>"
  echo "  2. 새 브랜치에서 commit하세요:"
  echo "     git add <파일> && git commit -m \"...\""
  echo "  3. 원격에 push하세요:"
  echo "     git push -u origin feat/<작업-설명>"
  echo ""
  echo "브랜치 이름은 사용자에게 AskUserQuestion으로 물어보세요."
  exit 2
fi

# git merge on main/master
if echo "$COMMAND" | grep -qE '\bgit\s+merge\b'; then
  block "$CURRENT_BRANCH 브랜치에서 직접 merge 불가" "PR을 통해 머지하세요: gh pr merge"
fi

exit 0

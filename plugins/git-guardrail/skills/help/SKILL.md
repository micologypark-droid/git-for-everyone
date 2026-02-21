---
name: help
description: git-guardrail 플러그인의 동작 방식, 차단 규칙, 우회 방법을 안내합니다. "가드레일 도움말", "git 안전장치", "뭐가 차단돼?" 같은 질문에 사용됩니다.
---

# git-guardrail 가이드

이 플러그인은 Claude Code가 위험한 Git 작업을 실행하지 못하도록 자동으로 차단합니다.
원격 작업(push, gh CLI)과 main/master 브랜치에서의 commit/merge를 감시합니다.

## 동작 원리

Bash 도구가 실행되기 전(PreToolUse) 명령어를 검사합니다.
위험한 패턴이 감지되면 exit code 2를 반환하여 실행 자체를 차단합니다.

## 차단 규칙

### 워크플로우 가드레일 (로컬)

GitHub Flow를 안내하기 위해 main/master 브랜치에서의 commit과 merge를 차단합니다.

| 명령어 | 브랜치 | 결과 |
|---|---|---|
| `git commit` | main/master | 차단 — feature 브랜치를 만들고 작업하세요 |
| `git merge feature` | main/master | 차단 — PR을 통해 머지하세요 |
| `git commit` | feature/* | 허용 |
| `git merge main` | feature/* | 허용 |

### 1. Force push 차단

| 명령어 | 결과 |
|---|---|
| `git push --force` | 차단 |
| `git push -f` | 차단 |
| `git push --force-with-lease` | 허용 |

`--force-with-lease`는 원격 브랜치 상태를 확인한 후 push하므로 안전합니다.

### 2. 보호 브랜치 직접 push 차단

보호 대상: `main`, `master`

| 명령어 | 결과 |
|---|---|
| `git push origin main` | 차단 |
| `git push origin master` | 차단 |
| `git push origin HEAD:main` | 차단 |
| `git push origin feature:main` | 차단 |
| `git push origin feature-branch` | 허용 |
| `git push origin main-fix` | 허용 (main이 독립 단어가 아님) |

`main` 브랜치에서 인자 없이 `git push`를 실행하는 경우도 차단됩니다.

### 3. GitHub CLI 가드레일

| 명령어 | 결과 | 이유 |
|---|---|---|
| `gh pr merge --admin` | 차단 | 브랜치 보호 규칙 우회 |
| `gh repo delete` | 차단 | 되돌릴 수 없는 작업 |
| `gh pr merge --squash` | 허용 | 정상적인 머지 |
| `gh pr create` | 허용 | PR 생성은 안전 |

## 허용 대상 (로컬 작업)

아래 명령어는 모두 제한 없이 실행됩니다:

- `git reset --hard` — 로컬 커밋 되돌리기
- `git clean -f` — 추적되지 않는 파일 삭제
- `git checkout .` — 변경사항 되돌리기
- `git restore .` — 변경사항 되돌리기
- `git branch -D` — 로컬 브랜치 삭제
- `git add` — staging
- `git commit` — feature 브랜치에서 허용 (main/master에서는 차단)
- 기타 모든 로컬 git 명령어

## 차단 메시지 형식

차단 시 다음과 같은 메시지가 출력됩니다:

```
BLOCKED: git push --force
  → Use --force-with-lease instead
```

첫 줄은 차단 사유, 두 번째 줄은 대안입니다.

## 자주 묻는 질문

**Q: main에 push하고 싶은데 차단됩니다**
A: feature 브랜치를 만들고 PR을 통해 머지하세요. 이것이 안전한 워크플로우입니다.

**Q: force push가 꼭 필요한 상황입니다**
A: `--force-with-lease`를 사용하세요. 원격 브랜치가 예상과 다르면 push를 거부하므로 더 안전합니다.

**Q: 새 저장소 초기 push가 차단됩니다**
A: 초기 push는 Claude 외부에서 직접 실행하거나, 플러그인을 일시적으로 비활성화하세요.

**Q: 특정 브랜치를 보호 대상에 추가하고 싶습니다**
A: `github-guardrail.sh`의 `(main|master)` 패턴에 브랜치명을 추가하세요. 예: `(main|master|develop)`

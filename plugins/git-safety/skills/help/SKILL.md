---
name: help
description: git-safety 플러그인의 동작 방식, 차단 규칙, 우회 방법을 안내합니다. "가드레일 도움말", "git 안전장치", "뭐가 차단돼?" 같은 질문에 사용됩니다.
---

# git-safety 가이드

git-safety는 여러분의 코드를 보호하는 안전장치입니다.

Git에는 실행하면 되돌리기 어려운 위험한 명령어들이 있습니다.
이 플러그인은 그런 명령어가 실행되기 전에 자동으로 막아주고, 더 안전한 방법을 알려줍니다.

내 컴퓨터(로컬)에서 하는 작업은 전혀 제한하지 않습니다.
GitHub(원격)에 영향을 주는 작업만 검사합니다.

## 이 플러그인은 어떻게 동작하나요?

Claude가 명령어를 실행하기 직전에 자동으로 검사합니다.
위험한 명령어가 감지되면 실행 자체를 막고, 왜 위험한지와 대신 쓸 수 있는 안전한 명령어를 알려줍니다.

여러분이 따로 설정하거나 신경 쓸 것은 없습니다. 설치만 하면 자동으로 동작합니다.

## 무엇을 막아주나요?

### 1. Force push (강제 밀어넣기)

`push`는 내 컴퓨터의 코드를 GitHub에 올리는 명령어입니다.
`force push`는 GitHub에 있는 코드를 무시하고 내 코드로 덮어쓰는 명령어입니다.

만약 다른 사람이 작업한 내용이 GitHub에 있다면, force push를 하면 그 작업이 사라질 수 있습니다.

| 명령어 | 결과 | 설명 |
|---|---|---|
| `git push --force` | 차단 | 원격 내용을 무조건 덮어씀 — 다른 사람 작업이 사라질 수 있음 |
| `git push -f` | 차단 | 위와 같음 (`-f`는 `--force`의 줄임말) |
| `git push --force-with-lease` | 허용 | 안전한 버전 — 누군가 먼저 push했으면 거부됨 |

`--force-with-lease`는 "다른 사람이 그 사이에 push한 게 없을 때만 force push해줘"라는 뜻입니다.
force push가 필요한 상황에서는 항상 이것을 사용하세요.

### 2. 보호 브랜치에 직접 push

`main`(또는 `master`) 브랜치는 프로젝트의 "완성본"이 들어있는 곳입니다.
여기에 직접 코드를 올리면 다른 팀원의 검토(코드 리뷰) 없이 코드가 반영됩니다.

| 명령어 | 결과 | 설명 |
|---|---|---|
| `git push origin main` | 차단 | main에 직접 push — 리뷰 없이 반영됨 |
| `git push origin master` | 차단 | master에 직접 push — 위와 같음 |
| `git push origin HEAD:main` | 차단 | 우회 방법도 감지하여 차단 |
| `git push origin feature-branch` | 허용 | feature 브랜치에 push — 안전함 |
| `git push origin main-fix` | 허용 | "main-fix"라는 이름의 feature 브랜치 — 안전함 |

main 브랜치에서 인자 없이 `git push`만 실행하는 경우도 차단됩니다.

대신 이렇게 하세요:
1. feature 브랜치를 만들어서 작업
2. feature 브랜치에 push
3. PR(Pull Request)을 만들어서 리뷰를 받은 후 main에 합치기

### 3. GitHub CLI 위험 명령어

`gh`는 터미널에서 GitHub를 사용하는 도구입니다. 그중 위험한 명령어를 차단합니다.

| 명령어 | 결과 | 설명 |
|---|---|---|
| `gh pr merge --admin` | 차단 | 관리자 권한으로 리뷰/CI 검사를 건너뛰고 머지 — 보호 규칙 무시 |
| `gh repo delete` | 차단 | 저장소(프로젝트) 전체를 삭제 — 되돌릴 수 없음 |
| `gh pr merge --squash` | 허용 | 정상적인 방법으로 PR을 머지 |
| `gh pr create` | 허용 | PR을 새로 만드는 것은 안전 |

## 내 컴퓨터에서 하는 작업은 자유입니다

아래 명령어는 내 컴퓨터에서만 동작하므로 전혀 제한하지 않습니다:

- `git add` — 파일을 커밋 준비 상태로 만들기
- `git commit` — 변경 내용을 저장(커밋)하기
- `git reset --hard` — 최근 커밋으로 되돌리기
- `git clean -f` — 새로 만든 파일 삭제하기
- `git checkout .` — 수정한 내용 원래대로 되돌리기
- `git branch -D` — 내 컴퓨터의 브랜치 삭제하기
- 기타 모든 로컬 git 명령어

핵심 원칙: GitHub(원격)에 영향을 주는 위험한 작업만 차단하고, 내 컴퓨터(로컬) 작업은 자유롭게 할 수 있습니다.

## 차단되면 어떻게 보이나요?

명령어가 차단되면 아래와 같은 메시지가 나타납니다:

```
차단: git push --force 사용 불가
  → --force-with-lease를 사용하세요
```

첫 줄은 왜 차단됐는지, 두 번째 줄은 대신 어떻게 하면 되는지 알려줍니다.

## 자주 묻는 질문

**Q: main에 push하고 싶은데 차단됩니다**
A: main에는 직접 push하지 않는 것이 안전합니다. 대신:
  1. `git checkout -b feat/내기능` — 새 브랜치를 만들고
  2. 그 브랜치에서 작업하고 push한 다음
  3. `gh pr create` — PR을 만들어서 main에 합치세요
이렇게 하면 실수로 잘못된 코드가 main에 들어가는 것을 막을 수 있습니다.

**Q: force push가 꼭 필요합니다**
A: `--force` 대신 `--force-with-lease`를 사용하세요.
예: `git push --force-with-lease origin my-branch`
이 옵션은 내가 마지막으로 확인한 이후에 다른 사람이 push한 게 있으면 자동으로 거부해줍니다.

**Q: 새 저장소를 만들고 처음 push하는데 차단됩니다**
A: 새 저장소의 첫 push는 Claude 외부의 터미널에서 직접 실행하세요.
한 번만 하면 되고, 이후부터는 feature 브랜치로 정상 작업하시면 됩니다.

**Q: 보호 브랜치를 추가하고 싶습니다 (예: develop)**
A: `github-guardrail.sh` 파일에서 `(main|master)` 부분을 `(main|master|develop)`으로 바꾸면 됩니다.

**Q: PR이 뭔가요?**
A: Pull Request(PR)는 "내 브랜치의 변경사항을 main에 합쳐주세요"라는 요청입니다.
PR을 만들면 다른 사람이 코드를 검토(리뷰)할 수 있고, 문제가 없으면 승인 후 합치게 됩니다.
혼자 작업할 때도 PR을 사용하면 변경 내역을 깔끔하게 관리할 수 있습니다.

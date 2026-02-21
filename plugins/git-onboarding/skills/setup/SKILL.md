---
name: setup
description: Git과 GitHub 초기 설정을 단계별로 진행합니다. "git 설정", "처음 시작", "GitHub 로그인", "깃 세팅" 같은 요청에 사용됩니다.
---

# Git 초기 설정 가이드

Git과 GitHub를 처음 사용하기 위한 설정을 단계별로 진행합니다.
이미 완료된 단계는 자동으로 건너뜁니다.

## 상태 수집

아래 7개 명령어를 **모두 병렬로** 실행하세요:

1. `which git` — Git 설치 여부
2. `git config --global user.name` — 사용자 이름
3. `git config --global user.email` — 이메일
4. `which gh 2>/dev/null && echo "installed" || echo "none"` — GitHub CLI 설치 여부
5. `gh auth status 2>&1` — GitHub 인증 상태 (출력에 "Logged in"이 포함되면 성공)
6. `git rev-parse --git-dir 2>/dev/null && echo "repo" || echo "no-repo"` — Git 저장소 여부
7. `test -x .git/hooks/pre-push && echo "exists" || echo "none"` — pre-push hook 설치 여부

## 진행 규칙

- 결과를 분석하여 이미 완료된 단계는 건너뛰세요.
- 첫 번째 미완료 단계부터 순서대로 진행하세요.
- 각 단계를 하나씩 완료한 후 다음 단계로 넘어가세요.
- 사용자 입력이 필요한 단계에서는 반드시 AskUserQuestion을 사용하세요.
- 모든 설명은 한국어로, Git을 처음 쓰는 사용자 눈높이에 맞추세요.

## 단계 1: Git 설치 확인

**완료 조건:** `which git`이 경로를 반환함

미설치인 경우 안내하세요:

```
Git이 설치되어 있지 않습니다.

터미널에서 아래 명령어를 직접 실행하세요:
  xcode-select --install

설치 팝업이 나타나면 "설치" 버튼을 클릭하세요.
설치가 완료되면 다시 /git-onboarding:setup 을 실행해주세요.
```

xcode-select는 GUI 팝업이 필요하므로 Claude가 직접 실행하지 마세요. 안내만 제공하고 이 단계에서 멈추세요.

## 단계 2: 사용자 이름 설정

**완료 조건:** `git config --global user.name`이 비어있지 않음

AskUserQuestion으로 이름을 물어보세요:

- question: "Git에서 사용할 이름을 입력하세요. 커밋 기록에 남는 이름입니다."
- header: "이름"
- options:
  - 현재 시스템 사용자 이름을 기본 옵션으로 제안

이름을 받으면 실행하세요:

```
git config --global user.name "<입력받은 이름>"
```

## 단계 3: 이메일 설정

**완료 조건:** `git config --global user.email`이 비어있지 않음

AskUserQuestion으로 이메일을 물어보세요:

- question: "Git에서 사용할 이메일을 입력하세요. GitHub 계정과 같은 이메일을 권장합니다. 이메일을 공개하고 싶지 않다면 GitHub의 noreply 이메일을 사용할 수 있습니다 (GitHub > Settings > Emails에서 확인)."
- header: "이메일"
- options:
  - "noreply 이메일 사용" — GitHub Settings > Emails에서 제공하는 비공개 이메일 (username@users.noreply.github.com)
  - "직접 입력" — 본인 이메일 주소를 직접 입력

이메일을 받으면 실행하세요:

```
git config --global user.email "<입력받은 이메일>"
```

## 단계 4: GitHub CLI 설치 확인

**완료 조건:** `which gh`가 경로를 반환함

미설치인 경우, AskUserQuestion으로 설치 방법을 안내하세요:

- question: "GitHub CLI(gh)가 설치되어 있지 않습니다. 어떤 방법으로 설치하시겠습니까?"
- header: "gh 설치"
- options:
  - "Homebrew로 설치 (Recommended)" — Mac 사용자에게 권장. `brew install gh`
  - "직접 설치" — https://cli.github.com 에서 다운로드

Homebrew를 선택한 경우:

```bash
brew install gh
```

직접 설치를 선택한 경우, 사용자에게 안내하세요:

```
아래 링크에서 GitHub CLI를 다운로드하여 설치하세요:
  https://cli.github.com

설치가 완료되면 다시 /git-onboarding:setup 을 실행해주세요.
```

직접 설치는 Claude가 실행할 수 없으므로 안내만 제공하고 이 단계에서 멈추세요.

## 단계 5: GitHub 로그인

**완료 조건:** `gh auth status 2>&1` 출력에 "Logged in"이 포함됨

GitHub에 로그인되어 있지 않은 경우, 사용자에게 안내하세요:

```
GitHub에 로그인해야 합니다.

터미널에서 아래 명령어를 직접 실행하세요:
  gh auth login

실행하면 몇 가지 선택지가 나옵니다:
  1. "GitHub.com" 선택
  2. 프로토콜은 "HTTPS" 선택
  3. 인증 방법은 "Login with a web browser" 선택
  4. 화면에 나오는 코드를 복사한 뒤 Enter
  5. 브라우저에서 코드를 붙여넣고 인증 완료

완료되면 다시 /git-onboarding:setup 을 실행해주세요.
```

`gh auth login`은 브라우저 인터랙션이 필요하므로 Claude가 직접 실행하지 마세요. 안내만 제공하고 이 단계에서 멈추세요.

사용자가 완료를 알리면 인증 상태를 확인하세요:

```bash
gh auth status 2>&1
```

"Logged in" 메시지가 나오면 성공입니다. 실패하면 로그인 과정을 다시 안내하세요.

## 단계 6: 저장소 준비

**완료 조건:** `git rev-parse --git-dir`이 성공 (현재 디렉토리가 Git 저장소)

Git 저장소가 아닌 경우, AskUserQuestion으로 방법을 물어보세요:

- question: "현재 디렉토리는 Git 저장소가 아닙니다. 어떻게 시작하시겠습니까?"
- header: "저장소"
- options:
  - "기존 저장소 clone" — GitHub에 이미 있는 저장소를 가져옴
  - "새 저장소 만들기" — 현재 폴더를 Git 저장소로 초기화

clone을 선택한 경우:
저장소 URL을 물어본 후 실행하세요:

```bash
git clone <URL>
```

새 저장소를 선택한 경우:

```bash
git init
```

## 단계 7: 메인 브랜치 보호 (pre-push hook)

**완료 조건:** `.git/hooks/pre-push` 파일이 존재하고 실행 권한이 있음

아래 명령어로 확인하세요:

```bash
test -x .git/hooks/pre-push && echo "exists" || echo "none"
```

pre-push hook이 없는 경우, 아래 내용으로 `.git/hooks/pre-push` 파일을 생성하세요:

```bash
#!/bin/sh

# Prevent direct push to protected branches (main/master)

while read local_ref local_sha remote_ref remote_sha; do
  if echo "$remote_ref" | grep -qE "refs/heads/(main|master)$"; then
    branch=$(echo "$remote_ref" | sed 's|refs/heads/||')
    echo ""
    echo "[BLOCKED] '$branch' 브랜치에 직접 push할 수 없습니다."
    echo ""
    echo "  새 브랜치를 만들어서 작업하세요:"
    echo "    git checkout -b <브랜치-이름>"
    echo "    git push -u origin <브랜치-이름>"
    echo ""
    exit 1
  fi
done

exit 0
```

파일 생성 후 실행 권한을 부여하세요:

```bash
chmod +x .git/hooks/pre-push
```

사용자에게 간단히 설명하세요:

```
pre-push hook을 설치했습니다.
이제 main/master 브랜치에서 직접 push하면 자동으로 차단됩니다.
새 브랜치를 만들어서 작업하는 습관을 기를 수 있습니다.
```

## 완료 메시지

모든 단계가 완료되면 설정 요약을 출력하세요:

```
Git 초기 설정이 완료되었습니다.

  이름:    <user.name>
  이메일:  <user.email>
  GitHub:  로그인됨
  저장소:  <현재 디렉토리>
  보호:    main/master push 차단 (pre-push hook)

다음 단계: /git-workflow:workflow 를 실행하면 브랜치 생성부터 PR까지 안내합니다.
```

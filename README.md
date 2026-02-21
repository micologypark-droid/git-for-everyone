# git-for-everyone

Claude Code에서 Git을 안전하고 쉽게 사용할 수 있도록 도와주는 플러그인입니다.

## 왜 필요한가요?

Git과 GitHub를 처음 사용하는 분을 위한 올인원 가이드입니다.

- 설정부터 PR까지 한 번에 자동 실행하는 완전 자동화 모드
- 설치부터 첫 push까지 9단계를 하나씩 안내
- GitHub 저장소 생성, remote 연결까지 자동 처리
- 팀 프로젝트 시 git hooks로 main 브랜치 보호 + conventional commits 강제
- 현재 상태를 분석하고 다음에 할 일을 안내하는 워크플로우 가이드

## 설치

Claude Code에서 플러그인을 설치하세요.

```
/plugin marketplace add https://github.com/ai-native-camp/git-for-everyone.git
/plugin install git-onboarding
```

## 명령어

| 명령어 | 설명 |
|---|---|
| `/git-onboarding-auto` | 설정 ~ 파일 생성 ~ 브랜치 ~ PR까지 완전 자동화 |
| `/git-onboarding-setup` | Git/GitHub 초기 설정 9단계 자동 진행 |
| `/git-onboarding-workflow` | 현재 git 상태 분석 → 다음 단계 안내 |
| `/git-onboarding-step` | 진행 상황 체크리스트 |
| `/git-onboarding-help` | 플러그인 가이드, 용어 설명, FAQ |

## auto — 완전 자동화

`/git-onboarding-auto`를 실행하면 현재 환경을 점검하고 미완료 항목을 자동으로 처리합니다.

1. 상태 점검 — git, gh, 인증, 저장소 등 전체 환경을 병렬로 확인
2. 자동 설정 — 미완료 항목을 순서대로 해결 (꼭 필요한 것만 질문)
3. 파일 생성 — 자기소개, 프로젝트 설명, 코드 중 선택
4. 브랜치 + 커밋 + push + PR 생성까지 한 번에 완료

이미 설정이 끝난 환경에서는 3단계부터 바로 시작합니다.

## setup 단계

| 단계 | 내용 |
|---|---|
| 1 | Git 설치 확인 |
| 2 | 사용자 이름 설정 |
| 3 | 이메일 설정 |
| 4 | GitHub CLI 설치 |
| 5 | GitHub 로그인 |
| 6 | 저장소 준비 (init 또는 clone) |
| 7 | GitHub 원격 저장소 생성 + remote 연결 |
| 8 | 원격 브랜치 초기화 (첫 push) |
| 9 | 작업 환경 선택 (개인/팀) |

단계 9에서 팀 프로젝트를 선택하면 git hooks가 자동 설치됩니다.
개인 프로젝트는 hooks 없이 설정이 완료됩니다.

## Git Hooks (팀 프로젝트)

팀 프로젝트 선택 시 `.git/hooks/`에 3개의 hook이 설치됩니다:

| Hook | 역할 |
|---|---|
| `pre-commit` | main/master에서 commit 차단 → 새 브랜치로 안내 |
| `commit-msg` | conventional commits 형식 검증 (feat:, fix:, docs: 등) |
| `pre-push` | main/master로 push 차단 → 새 브랜치로 안내 |

이 hook들은 터미널에서 직접 git을 사용할 때도 동작합니다.

## workflow 안내

`/git-onboarding-workflow`를 실행하면 현재 상태에 따라 다음 단계를 안내합니다:

| 상태 | 안내 |
|---|---|
| main, 변경 없음 | 새 브랜치 생성 안내 |
| main, 변경 있음 | feature 브랜치로 변경사항 이동 |
| feature, 미커밋 | commit 방법 안내 |
| feature, 미push | push + PR 생성 안내 |
| feature, clean | PR 상태 확인 |

## 라이선스

MIT

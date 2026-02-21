---
description: git-guardrail이 보호하는 실제 시나리오를 보여줍니다
---

아래는 git-guardrail 플러그인이 어떤 상황에서 동작하는지 보여주는 실제 시나리오입니다.
각 시나리오를 사용자에게 보여주세요. 코드 블록이나 도구 호출은 하지 마세요.

## 시나리오 1: 실수로 main에 직접 push

상황: feature 브랜치에서 작업하다가 main으로 checkout 후 습관적으로 push
  명령어: git push origin main
  결과: 차단
  이유: main 브랜치에 직접 push는 코드 리뷰 없이 프로덕션에 반영될 수 있음
  올바른 방법: feature 브랜치를 만들고 PR을 통해 머지

## 시나리오 2: force push로 동료 작업 덮어쓰기

상황: rebase 후 force push를 시도
  명령어: git push --force origin feature-branch
  결과: 차단
  이유: 동료가 같은 브랜치에 push한 커밋이 사라질 수 있음
  올바른 방법: git push --force-with-lease (원격이 변경됐으면 push 거부)

## 시나리오 3: refspec으로 보호 브랜치 우회 시도

상황: HEAD:main refspec으로 현재 브랜치를 main에 push
  명령어: git push origin HEAD:main
  결과: 차단
  이유: 브랜치 이름을 명시하지 않아도 결과적으로 main에 push됨
  올바른 방법: PR 워크플로우 사용

## 시나리오 4: admin 권한으로 PR 강제 머지

상황: CI가 실패했지만 급하게 머지하고 싶을 때
  명령어: gh pr merge 42 --admin
  결과: 차단
  이유: 브랜치 보호 규칙(리뷰 필수, CI 통과)을 무시하고 머지됨
  올바른 방법: CI를 고치고 정상적으로 머지 (gh pr merge 42 --squash)

## 시나리오 5: 저장소 실수 삭제

상황: 테스트 저장소를 삭제하려다 프로덕션 저장소를 삭제
  명령어: gh repo delete my-company/production-app
  결과: 차단
  이유: 저장소 삭제는 되돌릴 수 없음
  올바른 방법: Claude 외부에서 직접 확인하고 삭제

## 시나리오 6: 보호 브랜치에서 암묵적 push

상황: main 브랜치에서 인자 없이 git push 실행
  명령어: git push
  결과: 현재 브랜치가 main이면 차단
  이유: tracking 브랜치 설정에 따라 main에 push될 수 있음
  올바른 방법: feature 브랜치로 전환 후 push

## 허용되는 작업

아래 시나리오는 모두 허용됩니다 (로컬 작업이므로):

  git reset --hard HEAD~3    — 로컬 커밋 되돌리기
  git clean -fd              — 추적되지 않는 파일 정리
  git checkout .             — 변경사항 되돌리기
  git branch -D old-feature  — 로컬 브랜치 삭제
  git push origin feat-login — feature 브랜치 push (보호 대상 아님)

## 요약

이 플러그인의 핵심 원칙:
  1. 원격(remote)에 영향을 주는 위험한 작업만 차단
  2. 로컬 작업은 전혀 제한하지 않음
  3. 차단 시 항상 안전한 대안을 제시

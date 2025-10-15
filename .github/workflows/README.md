# GitHub Actions CI/CD 설정

## 워크플로우 설명

### docker-build.yml
- **트리거**: main, develop 브랜치에 push 또는 PR 생성
- **기능**: 
  - Docker 이미지 빌드 (멀티 아키텍처: linux/amd64, linux/arm64)
  - GitHub Container Registry에 푸시
  - 브랜치별 태그 전략 적용

### 이미지 태그 전략
- `main` 브랜치: `latest` 태그
- `develop` 브랜치: `dev` 태그  
- PR: `pr-{number}` 태그
- SHA 기반: `{branch}-{sha}` 태그

## 사전 설정

### 1. GitHub Container Registry 권한 설정
1. GitHub 저장소 → Settings → Actions → General
2. "Workflow permissions" → "Read and write permissions" 선택
3. "Allow GitHub Actions to create and approve pull requests" 체크

### 2. 저장소 Secrets 확인
필요한 경우 다음 Secrets 설정:
- `GITHUB_TOKEN`: 자동으로 제공됨
- `DOCKER_USERNAME`: GitHub 사용자명
- `DOCKER_PASSWORD`: GitHub Personal Access Token

## 워크플로우 실행

### 수동 실행
1. GitHub 저장소 → Actions 탭
2. "Build and Push Docker Image" 워크플로우 선택
3. "Run workflow" 버튼 클릭

### 자동 실행
- `main` 또는 `develop` 브랜치에 코드 push
- Pull Request 생성

## 빌드 결과 확인

### 1. Actions 탭에서 빌드 상태 확인
- 녹색 체크: 성공
- 빨간색 X: 실패
- 노란색 원: 진행 중

### 2. Container Registry에서 이미지 확인
- GitHub 저장소 → Packages 탭
- 또는 `ghcr.io/{username}/{repository}` 직접 접속

### 3. ArgoCD에서 자동 감지 확인
- ArgoCD UI → Applications
- 새 이미지 감지 및 자동 동기화 확인

## 문제 해결

### 빌드 실패
1. Actions 탭에서 로그 확인
2. Dockerfile 문법 오류 체크
3. 의존성 설치 문제 확인

### 이미지 푸시 실패
1. Container Registry 권한 확인
2. GitHub Token 권한 확인
3. 저장소 이름 확인

### ArgoCD 동기화 실패
1. ArgoCD 로그 확인
2. Git 저장소 접근 권한 확인
3. Kubernetes 매니페스트 문법 확인

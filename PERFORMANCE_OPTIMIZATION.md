# 🚀 Docker 빌드 성능 최적화 가이드

## 📊 성능 개선 결과

### 이전 (16분+)

- 멀티 아키텍처 빌드 (linux/amd64, linux/arm64)
- 모든 브랜치에서 동일한 빌드 전략
- 캐시 미활용

### 개선 후 (예상)

- **모든 빌드**: 2-5분 (단일 아키텍처 linux/amd64)
- **초고속 빌드**: 1-3분 (최대 최적화)
- **타임아웃**: 5-8분 설정

## 🔧 최적화 전략

### 1. 단일 아키텍처 빌드 전략

```yaml
# 모든 빌드에서 단일 아키텍처 사용
build-and-push:
  platforms: linux/amd64 # 단일 아키텍처로 통일
  timeout-minutes: 8 # 타임아웃 설정
```

### 2. Docker 캐시 최적화

```yaml
cache-from: type=gha
cache-to: type=gha,mode=max
build-args: |
  BUILDKIT_INLINE_CACHE=1
```

### 3. Dockerfile 최적화

- `npm ci --only=production` - 프로덕션 의존성만 설치
- `npm cache clean --force` - 캐시 정리
- 불필요한 파일 제거

## 📋 워크플로우별 사용법

### 1. 기본 워크플로우 (docker-build.yml)

- **용도**: 일반적인 CI/CD
- **빌드 시간**: 2-5분
- **사용 시점**: 자동 트리거

### 2. 초고속 워크플로우 (docker-build-fast.yml)

- **용도**: 개발 중 빠른 테스트
- **빌드 시간**: 1-3분
- **사용 시점**: 수동 실행 또는 develop 브랜치

## 🛠️ 추가 최적화 방법

### 1. .dockerignore 최적화

```dockerignore
# 불필요한 파일 제외
node_modules
.git
.next
.env*
*.log
README.md
.github
k8s
argocd
scripts
```

### 2. 멀티스테이지 빌드 최적화

```dockerfile
# 의존성 설치 최적화
RUN npm ci --only=production --silent && \
    npm cache clean --force && \
    rm -rf /tmp/* /var/cache/apk/*
```

### 3. 빌드 인수 최적화

```yaml
build-args: |
  BUILDKIT_INLINE_CACHE=1
  NODE_ENV=production
```

## 📈 성능 모니터링

### 빌드 시간 확인

1. GitHub Actions → 해당 워크플로우
2. "Build and push Docker image" 단계 시간 확인
3. 로그에서 각 단계별 소요 시간 분석

### 캐시 효율성 확인

```bash
# 로컬에서 캐시 상태 확인
docker system df
docker builder prune --filter until=24h
```

## 🎯 권장 사용 패턴

### 개발 단계

1. **로컬 개발**: `docker build -t app .`
2. **PR 테스트**: 자동으로 빠른 빌드 실행 (2-5분)
3. **수동 테스트**: `docker-build-fast.yml` 수동 실행 (1-3분)

### 배포 단계

1. **스테이징**: develop 브랜치 → 빠른 빌드 (2-5분)
2. **프로덕션**: main 브랜치 → 빠른 빌드 (2-5분)

## 🔍 문제 해결

### 빌드 시간이 여전히 긴 경우

1. **캐시 확인**: GitHub Actions 캐시 상태 확인
2. **의존성 확인**: package.json 변경 여부 확인
3. **네트워크 확인**: Docker Hub 연결 상태 확인

### 캐시 미적용 문제

1. **캐시 키 확인**: GitHub Actions 캐시 키 설정
2. **빌드 컨텍스트 확인**: .dockerignore 설정
3. **Dockerfile 레이어 확인**: 레이어 순서 최적화

## 📊 예상 성능 개선

| 시나리오      | 이전 시간 | 개선 후 | 개선율 |
| ------------- | --------- | ------- | ------ |
| 모든 빌드     | 16분+     | 2-5분   | 70-85% |
| 초고속 빌드   | 16분+     | 1-3분   | 80-90% |
| 타임아웃 설정 | 무제한    | 5-8분   | 안정성 |

## 🚀 추가 최적화 아이디어

### 1. 병렬 빌드

- 여러 환경을 동시에 빌드
- 테스트와 빌드를 병렬 실행

### 2. 레이어 캐싱

- 베이스 이미지 캐싱
- 의존성 레이어 분리

### 3. 빌드 최적화

- 불필요한 파일 제거
- 압축 최적화
- 멀티스테이지 빌드 세분화

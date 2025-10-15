# 🐛 Docker 빌드 문제 해결 가이드

## ❌ 일반적인 빌드 오류들

### 1. `npm run build` 실패 (exit code: 1)

#### 원인

- `npm ci --only=production` 사용 시 devDependencies가 설치되지 않음
- TypeScript 컴파일러가 없어서 빌드 실패
- Next.js 빌드에 필요한 devDependencies 누락

#### 해결 방법

```dockerfile
# ❌ 잘못된 방법
RUN npm ci --only=production

# ✅ 올바른 방법
RUN npm ci  # 모든 의존성 설치 (빌드용)
```

### 2. 메모리 부족 오류

#### 원인

- GitHub Actions 기본 메모리 제한
- Node.js 빌드 시 메모리 사용량 증가

#### 해결 방법

```yaml
# GitHub Actions 워크플로우에 추가
jobs:
  build-and-push:
    runs-on: ubuntu-latest
    timeout-minutes: 8
    # 메모리 최적화
    steps:
      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          build-args: |
            NODE_OPTIONS=--max-old-space-size=4096
```

### 3. 캐시 관련 오류

#### 원인

- GitHub Actions 캐시 손상
- Docker 레이어 캐시 불일치

#### 해결 방법

```bash
# 로컬에서 캐시 정리
docker system prune -a
docker builder prune -a

# GitHub Actions에서 캐시 무효화
# Actions 탭 → 해당 워크플로우 → "Clear cache" 버튼
```

## 🔧 빌드 최적화 팁

### 1. 의존성 설치 최적화

```dockerfile
# 패키지 파일만 먼저 복사 (캐시 효율성)
COPY package.json package-lock.json* ./
RUN npm ci && npm cache clean --force

# 소스 코드는 나중에 복사
COPY . .
```

### 2. 멀티스테이지 빌드 활용

```dockerfile
# 빌드용 스테이지 (모든 의존성 필요)
FROM node:18-alpine AS builder
RUN npm ci  # devDependencies 포함

# 런타임용 스테이지 (프로덕션 의존성만)
FROM node:18-alpine AS runner
# 빌드된 파일만 복사
```

### 3. 환경 변수 최적화

```dockerfile
# 빌드 시점에 설정
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production
```

## 🚀 성능 개선 방법

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

### 2. 레이어 캐싱

```yaml
# GitHub Actions에서
cache-from: type=gha
cache-to: type=gha,mode=max
```

### 3. 빌드 인수 최적화

```yaml
build-args: |
  BUILDKIT_INLINE_CACHE=1
  NODE_ENV=production
```

## 🔍 디버깅 방법

### 1. 로컬 빌드 테스트

```bash
# 기본 빌드
docker build -t test-app .

# 상세 로그와 함께 빌드
docker build --progress=plain --no-cache -t test-app .

# 특정 스테이지까지 빌드
docker build --target builder -t test-app .
```

### 2. 중간 컨테이너 확인

```bash
# 빌드 실패 시 중간 컨테이너 실행
docker run -it --rm <image-id> /bin/sh

# 의존성 확인
docker run -it --rm <image-id> npm list
```

### 3. GitHub Actions 로그 분석

1. Actions 탭 → 실패한 워크플로우
2. "Build and push Docker image" 단계 클릭
3. 로그에서 오류 메시지 확인

## 📋 체크리스트

### 빌드 전 확인사항

- [ ] `package.json`에 모든 필요한 의존성 포함
- [ ] `next.config.ts` 설정 확인
- [ ] `.dockerignore` 파일 존재
- [ ] TypeScript 설정 파일 존재

### 빌드 중 확인사항

- [ ] 의존성 설치 완료
- [ ] TypeScript 컴파일 성공
- [ ] Next.js 빌드 성공
- [ ] 이미지 생성 완료

### 빌드 후 확인사항

- [ ] 컨테이너 실행 테스트
- [ ] 애플리케이션 정상 동작
- [ ] 포트 3000 접근 가능

## 🆘 긴급 해결 방법

### 빌드가 계속 실패하는 경우

1. **기본 Dockerfile 사용**

   ```bash
   # Dockerfile.safe 사용
   docker build -f Dockerfile.safe -t app .
   ```

2. **캐시 완전 무시**

   ```bash
   docker build --no-cache -t app .
   ```

3. **단계별 빌드**

   ```bash
   # 의존성 설치만 테스트
   docker build --target deps -t app .

   # 빌드만 테스트
   docker build --target builder -t app .
   ```

## 📞 추가 도움

문제가 지속되면 다음을 확인하세요:

1. Node.js 버전 호환성
2. Next.js 버전 호환성
3. TypeScript 설정
4. GitHub Actions 리소스 제한

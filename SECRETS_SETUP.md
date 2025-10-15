# 시크릿 설정 가이드

## 🔐 필요한 시크릿 값들

### 1. GitHub Personal Access Token (ArgoCD Image Updater용)

#### 생성 방법:

1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. "Generate new token (classic)" 클릭
3. 다음 권한 선택:
   - `read:packages` - Container Registry 읽기
   - `write:packages` - Container Registry 쓰기
   - `repo` - 저장소 접근 (private repo인 경우)
4. 토큰 생성 후 복사 (한 번만 표시됨)

#### ArgoCD에 설정:

```bash
# GitHub Personal Access Token을 ArgoCD Secret으로 생성
kubectl create secret generic ghcr-token \
  --from-literal=username=YOUR_GITHUB_USERNAME \
  --from-literal=password=YOUR_PERSONAL_ACCESS_TOKEN \
  -n argocd

# 또는 YAML로 생성
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ghcr-token
  namespace: argocd
type: Opaque
stringData:
  username: YOUR_GITHUB_USERNAME
  password: YOUR_PERSONAL_ACCESS_TOKEN
EOF
```

### 2. ArgoCD 관리자 비밀번호

#### 설치 후 확인:

```bash
# ArgoCD 설치 후 초기 비밀번호 확인
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

#### 비밀번호 변경 (선택사항):

```bash
# ArgoCD CLI로 로그인 후 비밀번호 변경
argocd login localhost:8080
argocd account update-password
```

## 🚀 설정 순서

### 1단계: GitHub Personal Access Token 생성

1. GitHub에서 Personal Access Token 생성
2. 위의 명령어로 ArgoCD Secret 생성

### 2단계: ArgoCD 설치

```bash
./scripts/install-argocd.sh
```

### 3단계: ArgoCD Image Updater 설치

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml
kubectl apply -f argocd/image-updater-config.yaml
```

### 4단계: Application 배포

```bash
kubectl apply -f argocd/app-dev-with-updater.yaml
```

## 🔍 확인 방법

### GitHub Actions 권한 확인:

1. GitHub 저장소 → Settings → Actions → General
2. "Workflow permissions" → "Read and write permissions" 선택
3. "Allow GitHub Actions to create and approve pull requests" 체크

### ArgoCD Image Updater 동작 확인:

```bash
# Image Updater 로그 확인
kubectl logs -n argocd deployment/argocd-image-updater

# Application 상태 확인
argocd app get serverful-study-dev
```

## ⚠️ 주의사항

1. **Personal Access Token 보안**: 토큰을 안전하게 보관하고 정기적으로 갱신
2. **권한 최소화**: 필요한 최소한의 권한만 부여
3. **토큰 만료**: 토큰 만료일을 확인하고 갱신
4. **Secret 관리**: Kubernetes Secret을 안전하게 관리

## 🐛 문제 해결

### Image Updater가 이미지를 감지하지 못하는 경우:

1. GitHub Personal Access Token 권한 확인
2. Container Registry 접근 권한 확인
3. Image Updater 로그 확인

### GitHub Actions 빌드 실패:

1. 저장소 권한 설정 확인
2. GITHUB_TOKEN 권한 확인
3. Dockerfile 문법 확인

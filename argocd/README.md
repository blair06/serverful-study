# ArgoCD 설치 및 설정

## ArgoCD 설치

### 1. ArgoCD 설치
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 2. ArgoCD CLI 설치 (macOS)
```bash
brew install argocd
```

### 3. 포트 포워딩 및 접속
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

웹 브라우저에서 `https://localhost:8080` 접속

### 4. 초기 관리자 비밀번호 확인
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## ArgoCD Image Updater 설치

### 1. Image Updater 설치
```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml
```

### 2. 설정 적용
```bash
kubectl apply -f argocd/image-updater-config.yaml
```

## Application 배포

### 개발 환경
```bash
kubectl apply -f argocd/app-dev.yaml
```

### 운영 환경
```bash
kubectl apply -f argocd/app-prod.yaml
```

### Image Updater가 포함된 개발 환경
```bash
kubectl apply -f argocd/app-dev-with-updater.yaml
```

## 유용한 명령어

### ArgoCD CLI 로그인
```bash
argocd login localhost:8080
```

### Application 상태 확인
```bash
argocd app list
argocd app get serverful-study-dev
```

### 수동 동기화
```bash
argocd app sync serverful-study-dev
```

### Application 삭제
```bash
argocd app delete serverful-study-dev
```

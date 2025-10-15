# 🔧 ArgoCD 문제 해결 가이드

## ❌ 일반적인 ArgoCD 문제들

### 1. Application이 보이지 않음

#### 원인

- ArgoCD Application CRD가 배포되지 않음
- ArgoCD 서버가 실행되지 않음
- 네임스페이스 문제

#### 해결 방법

```bash
# 1. ArgoCD 서버 상태 확인
kubectl get pods -n argocd

# 2. Application 배포
kubectl apply -f argocd/app-simple.yaml

# 3. Application 목록 확인
kubectl get applications -n argocd
```

### 2. Application이 OutOfSync 상태

#### 원인

- Git 저장소 접근 불가
- 매니페스트 파일 경로 오류
- 이미지 태그 불일치

#### 해결 방법

```bash
# 1. Git 저장소 접근 확인
kubectl get application serverful-study-simple -n argocd -o yaml

# 2. 수동 동기화
argocd app sync serverful-study-simple

# 3. 로그 확인
kubectl logs -n argocd deployment/argocd-server
```

### 3. 이미지를 찾을 수 없음

#### 원인

- 이미지 경로 불일치
- 이미지 태그 오류
- Docker Hub 접근 권한 문제

#### 해결 방법

```bash
# 1. 이미지 경로 확인
kubectl get deployment -n serverful-study -o yaml | grep image

# 2. 이미지 태그 확인
docker pull docker.io/YOUR_USERNAME/serverful-study:latest

# 3. Kustomization 이미지 설정 확인
cat k8s/base/kustomization.yaml
```

## 🚀 단계별 해결 방법

### 1단계: ArgoCD 설치 확인

```bash
# ArgoCD 설치 스크립트 실행
./scripts/install-argocd.sh

# 또는 수동 설치
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 2단계: Application 배포

```bash
# 간단한 Application 배포
kubectl apply -f argocd/app-simple.yaml

# 또는 배포 스크립트 실행
./scripts/deploy-argocd-apps.sh
```

### 3단계: 상태 확인

```bash
# Application 상태 확인
kubectl get applications -n argocd

# Pod 상태 확인
kubectl get pods -n serverful-study

# 서비스 상태 확인
kubectl get svc -n serverful-study
```

## 🔍 디버깅 명령어

### ArgoCD 상태 확인

```bash
# ArgoCD 컴포넌트 상태
kubectl get pods -n argocd

# ArgoCD 서버 로그
kubectl logs -n argocd deployment/argocd-server

# ArgoCD Application Controller 로그
kubectl logs -n argocd deployment/argocd-application-controller
```

### Application 상세 정보

```bash
# Application 상세 정보
kubectl get application serverful-study-simple -n argocd -o yaml

# Application 이벤트
kubectl describe application serverful-study-simple -n argocd

# Application 리소스 상태
kubectl get application serverful-study-simple -n argocd -o jsonpath='{.status.resources}'
```

### Kubernetes 리소스 확인

```bash
# 네임스페이스 확인
kubectl get namespaces | grep serverful-study

# 배포 상태 확인
kubectl get deployments -n serverful-study

# Pod 로그 확인
kubectl logs -n serverful-study deployment/serverful-study
```

## 🛠️ 일반적인 수정 방법

### 1. 이미지 경로 수정

```yaml
# k8s/base/kustomization.yaml
images:
  - name: docker.io/YOUR_USERNAME/serverful-study
    newTag: latest
```

### 2. Git 저장소 URL 수정

```yaml
# argocd/app-simple.yaml
spec:
  source:
    repoURL: https://github.com/YOUR_USERNAME/serverful-study.git
```

### 3. 네임스페이스 수정

```yaml
# argocd/app-simple.yaml
spec:
  destination:
    namespace: serverful-study
```

## 🎯 빠른 해결 방법

### 1. 완전 초기화

```bash
# 기존 Application 삭제
kubectl delete application serverful-study-simple -n argocd

# 네임스페이스 삭제
kubectl delete namespace serverful-study

# 새로 배포
kubectl apply -f argocd/app-simple.yaml
```

### 2. 수동 동기화

```bash
# ArgoCD CLI 로그인
argocd login localhost:8080

# Application 동기화
argocd app sync serverful-study-simple

# 강제 동기화
argocd app sync serverful-study-simple --force
```

### 3. 웹 UI에서 확인

1. `https://localhost:8080` 접속
2. admin 계정으로 로그인
3. Applications 탭에서 상태 확인
4. SYNC 버튼 클릭

## 📋 체크리스트

### ArgoCD 설치 확인

- [ ] ArgoCD 네임스페이스 존재
- [ ] ArgoCD 서버 실행 중
- [ ] 포트 포워딩 설정
- [ ] 웹 UI 접근 가능

### Application 배포 확인

- [ ] Application CRD 배포됨
- [ ] Git 저장소 접근 가능
- [ ] 매니페스트 경로 정확
- [ ] 이미지 경로 정확

### Kubernetes 리소스 확인

- [ ] 네임스페이스 생성됨
- [ ] Deployment 실행 중
- [ ] Service 생성됨
- [ ] Pod 정상 실행

## 🆘 긴급 해결 방법

### Application이 전혀 보이지 않는 경우

```bash
# 1. ArgoCD 재시작
kubectl rollout restart deployment/argocd-server -n argocd

# 2. 간단한 Application 배포
kubectl apply -f argocd/app-simple.yaml

# 3. 웹 UI에서 확인
```

### 이미지 Pull 실패하는 경우

```bash
# 1. 이미지 존재 확인
docker pull docker.io/YOUR_USERNAME/serverful-study:latest

# 2. 이미지 태그 수정
# k8s/base/kustomization.yaml에서 이미지 경로 확인

# 3. 수동으로 이미지 태그 설정
kubectl set image deployment/serverful-study serverful-study=docker.io/YOUR_USERNAME/serverful-study:latest -n serverful-study
```

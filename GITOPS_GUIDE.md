# ArgoCD GitOps 실습 가이드

이 프로젝트는 ArgoCD를 사용한 GitOps 배포 자동화를 학습하기 위한 실습 환경입니다.

## 📋 목표

- ArgoCD 설치 및 Git 연동
- GitOps 배포 자동화 구성
- GitHub Actions CI/CD 파이프라인 구성
- Docker 이미지 자동 업데이트

## 🏗️ 프로젝트 구조

```
serverful-study/
├── .github/workflows/          # GitHub Actions 워크플로우
├── argocd/                     # ArgoCD 설정 파일
├── k8s/                        # Kubernetes 매니페스트
│   ├── base/                   # 기본 매니페스트
│   └── overlays/               # 환경별 오버레이
│       ├── dev/                # 개발 환경
│       └── prod/               # 운영 환경
├── scripts/                    # 설치 스크립트
├── Dockerfile                  # Docker 이미지 빌드
└── README.md                   # 이 파일
```

## 🚀 시작하기

### 1. 사전 요구사항

- Kubernetes 클러스터 (minikube, kind, 또는 클라우드)
- kubectl 설치 및 클러스터 접근 권한
- Docker 설치
- Git 설치

### 2. ArgoCD 설치

```bash
# ArgoCD 설치 스크립트 실행
./scripts/install-argocd.sh
```

또는 수동 설치:

```bash
# ArgoCD 네임스페이스 생성
kubectl create namespace argocd

# ArgoCD 설치
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 서버 준비 대기
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# 포트 포워딩
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 3. ArgoCD 접속

1. 웹 브라우저에서 `https://localhost:8080` 접속
2. 초기 관리자 비밀번호 확인:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```
3. Username: `admin`, Password: 위에서 확인한 비밀번호

## 📚 실습 단계

### 단계 1: 수동 배포 (Webhook 없는 상태)

1. **ArgoCD Application 생성**
   ```bash
   kubectl apply -f argocd/app-dev.yaml
   ```

2. **ArgoCD UI에서 확인**
   - Applications 페이지에서 `serverful-study-dev` 확인
   - SYNC 버튼을 클릭하여 수동 배포 실행

3. **배포 상태 확인**
   ```bash
   kubectl get pods -n serverful-study-dev
   kubectl get svc -n serverful-study-dev
   ```

### 단계 2: GitHub Actions CI/CD 구성

1. **GitHub 저장소 설정**
   - GitHub Actions 활성화
   - Container Registry 권한 설정

2. **Docker 이미지 빌드 및 푸시**
   - 코드 변경 후 push
   - GitHub Actions에서 자동 빌드 확인
   - Container Registry에 이미지 푸시 확인

3. **ArgoCD 자동 동기화**
   - ArgoCD가 새 이미지 감지
   - 자동 배포 실행

### 단계 3: 이미지 업데이트 자동화

1. **ArgoCD Image Updater 설치**
   ```bash
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml
   ```

2. **Image Updater 설정**
   ```bash
   kubectl apply -f argocd/image-updater-config.yaml
   ```

3. **자동 업데이트 Application 적용**
   ```bash
   kubectl apply -f argocd/app-dev-with-updater.yaml
   ```

## 🔧 주요 구성 요소

### Kubernetes 매니페스트

- **Namespace**: 환경별 네임스페이스 분리
- **Deployment**: 애플리케이션 배포 설정
- **Service**: 내부 서비스 노출
- **Ingress**: 외부 접근 설정

### ArgoCD 설정

- **Application**: GitOps 애플리케이션 정의
- **AppProject**: 프로젝트 권한 및 정책 설정
- **Image Updater**: 자동 이미지 업데이트 설정

### GitHub Actions

- **Docker Build**: 멀티 아키텍처 이미지 빌드
- **Container Registry**: GitHub Container Registry 푸시
- **자동 트리거**: 브랜치별 빌드 전략

## 🎯 학습 포인트

### GitOps 개념
- 선언적 설정 관리
- Git을 단일 진실 소스로 사용
- 자동화된 배포 파이프라인

### ArgoCD 기능
- Application CRD를 통한 애플리케이션 관리
- 실시간 상태 모니터링
- 수동/자동 동기화 비교

### CI/CD 파이프라인
- GitHub Actions 워크플로우 구성
- Docker 이미지 빌드 및 푸시
- 이미지 태그 전략 (브랜치/SHA 기반)

## 🐛 문제 해결

### 일반적인 문제들

1. **ArgoCD 접속 불가**
   ```bash
   # 포트 포워딩 확인
   kubectl get svc -n argocd
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

2. **Application 동기화 실패**
   ```bash
   # ArgoCD 로그 확인
   kubectl logs -n argocd deployment/argocd-server
   ```

3. **이미지 업데이트 실패**
   ```bash
   # Image Updater 로그 확인
   kubectl logs -n argocd deployment/argocd-image-updater
   ```

## 📖 추가 학습 자료

- [ArgoCD 공식 문서](https://argo-cd.readthedocs.io/)
- [GitOps 개념](https://www.gitops.tech/)
- [Kubernetes 매니페스트 작성 가이드](https://kubernetes.io/docs/concepts/)
- [GitHub Actions 문서](https://docs.github.com/en/actions)

## 🤝 기여하기

이 실습 프로젝트에 기여하고 싶으시다면:

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

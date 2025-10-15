# Kubernetes 매니페스트 구조

## 디렉토리 구조

```
k8s/
├── base/                    # 기본 매니페스트
│   ├── namespace.yaml       # 네임스페이스 정의
│   ├── deployment.yaml      # 애플리케이션 배포 설정
│   ├── service.yaml         # 서비스 노출 설정
│   ├── ingress.yaml         # 외부 접근 설정
│   └── kustomization.yaml   # Kustomize 기본 설정
└── overlays/                # 환경별 오버레이
    ├── dev/                 # 개발 환경
    │   ├── kustomization.yaml
    │   └── deployment-patch.yaml
    └── prod/                # 운영 환경
        ├── kustomization.yaml
        └── deployment-patch.yaml
```

## Kustomize 사용법

### 기본 매니페스트 적용
```bash
kubectl apply -k k8s/base
```

### 개발 환경 적용
```bash
kubectl apply -k k8s/overlays/dev
```

### 운영 환경 적용
```bash
kubectl apply -k k8s/overlays/prod
```

### 매니페스트 미리보기
```bash
kubectl kustomize k8s/overlays/dev
```

## 환경별 차이점

### 개발 환경 (dev)
- **네임스페이스**: `serverful-study-dev`
- **레플리카**: 1개
- **리소스**: 낮은 요청량 (128Mi, 100m)
- **이미지 태그**: `dev`
- **환경 변수**: `NODE_ENV=development`

### 운영 환경 (prod)
- **네임스페이스**: `serverful-study-prod`
- **레플리카**: 3개
- **리소스**: 높은 요청량 (512Mi, 500m)
- **이미지 태그**: `latest`
- **환경 변수**: `NODE_ENV=production`

## 주요 구성 요소

### Namespace
- 환경별 네임스페이스 분리
- 리소스 격리 및 관리

### Deployment
- 애플리케이션 배포 설정
- 레플리카 수, 리소스 제한
- 헬스체크 설정 (liveness, readiness)

### Service
- 내부 서비스 노출
- ClusterIP 타입 사용
- 포트 매핑: 80 → 3000

### Ingress
- 외부 접근 설정
- NGINX Ingress Controller 사용
- TLS 설정 포함

## 커스터마이징

### 리소스 수정
1. `base/deployment.yaml`에서 기본 설정 수정
2. `overlays/{env}/deployment-patch.yaml`에서 환경별 오버라이드

### 새로운 환경 추가
1. `overlays/{env}/` 디렉토리 생성
2. `kustomization.yaml` 및 패치 파일 생성
3. ArgoCD Application CRD 생성

## 배포 전략

### Blue-Green 배포
- 두 개의 동일한 환경 구성
- 트래픽 전환을 통한 무중단 배포

### Rolling Update
- 기본 Kubernetes 배포 전략
- 점진적 파드 교체

### Canary 배포
- 소량 트래픽으로 새 버전 테스트
- 점진적 트래픽 증가

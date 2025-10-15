#!/bin/bash

# ArgoCD 설치 및 설정 스크립트
# 이 스크립트는 Kubernetes 클러스터에 ArgoCD를 설치하고 기본 설정을 수행합니다.

set -e

echo "🚀 ArgoCD 설치를 시작합니다..."

# ArgoCD 네임스페이스 생성
echo "📦 ArgoCD 네임스페이스 생성 중..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# ArgoCD 설치
echo "⬇️ ArgoCD 설치 중..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# ArgoCD 서버가 준비될 때까지 대기
echo "⏳ ArgoCD 서버 준비 대기 중..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# ArgoCD CLI 설치 (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "📥 ArgoCD CLI 설치 중 (macOS)..."
    if ! command -v argocd &> /dev/null; then
        brew install argocd
    else
        echo "✅ ArgoCD CLI가 이미 설치되어 있습니다."
    fi
else
    echo "⚠️ ArgoCD CLI를 수동으로 설치해주세요: https://argo-cd.readthedocs.io/en/stable/cli_installation/"
fi

# ArgoCD 서버 포트 포워딩 시작 (백그라운드)
echo "🌐 ArgoCD 서버 포트 포워딩 시작..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
PORT_FORWARD_PID=$!

# 포트 포워딩이 준비될 때까지 대기
sleep 5

# 초기 관리자 비밀번호 가져오기
echo "🔑 초기 관리자 비밀번호:"
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"

echo ""
echo "🎉 ArgoCD 설치가 완료되었습니다!"
echo "📱 ArgoCD 웹 UI: https://localhost:8080"
echo "👤 로그인 정보:"
echo "   - Username: admin"
echo "   - Password: $ARGOCD_PASSWORD"
echo ""
echo "🔧 다음 단계:"
echo "1. 웹 브라우저에서 https://localhost:8080 접속"
echo "2. admin 계정으로 로그인"
echo "3. Git 저장소 연결 설정"
echo "4. Application 생성"
echo ""
echo "⚠️ 포트 포워딩을 중지하려면: kill $PORT_FORWARD_PID"
echo "📚 자세한 내용은 README.md를 참조하세요."

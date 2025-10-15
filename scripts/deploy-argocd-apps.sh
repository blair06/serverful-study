#!/bin/bash

# ArgoCD Application 배포 스크립트
# 이 스크립트는 ArgoCD Application들을 배포하고 상태를 확인합니다.

set -e

echo "🚀 ArgoCD Application 배포를 시작합니다..."

# ArgoCD 네임스페이스 확인
echo "📦 ArgoCD 네임스페이스 확인 중..."
kubectl get namespace argocd > /dev/null 2>&1 || {
    echo "❌ ArgoCD 네임스페이스가 존재하지 않습니다. 먼저 ArgoCD를 설치해주세요."
    echo "   ./scripts/install-argocd.sh 실행"
    exit 1
}

# ArgoCD 서버 상태 확인
echo "🔍 ArgoCD 서버 상태 확인 중..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd || {
    echo "❌ ArgoCD 서버가 준비되지 않았습니다."
    exit 1
}

# Project 배포
echo "📋 ArgoCD Project 배포 중..."
kubectl apply -f argocd/project.yaml

# Application 배포
echo "🚀 ArgoCD Application 배포 중..."

# 개발 환경 Application
echo "  - 개발 환경 Application 배포..."
kubectl apply -f argocd/app-dev.yaml

# 운영 환경 Application
echo "  - 운영 환경 Application 배포..."
kubectl apply -f argocd/app-prod.yaml

# 배포 상태 확인
echo "⏳ Application 배포 상태 확인 중..."
sleep 10

# Application 목록 확인
echo "📋 배포된 Application 목록:"
kubectl get applications -n argocd

echo ""
echo "🔍 Application 상세 상태:"
kubectl get applications -n argocd -o wide

echo ""
echo "📊 Application 상태 요약:"
for app in serverful-study-dev serverful-study-prod; do
    echo "  - $app:"
    kubectl get application $app -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null || echo "    상태 확인 실패"
    kubectl get application $app -n argocd -o jsonpath='{.status.health.status}' 2>/dev/null || echo "    헬스 확인 실패"
done

echo ""
echo "🎉 ArgoCD Application 배포가 완료되었습니다!"
echo ""
echo "📱 ArgoCD 웹 UI에서 확인하세요:"
echo "   https://localhost:8080 (포트 포워딩 필요)"
echo ""
echo "🔧 유용한 명령어:"
echo "   # Application 상태 확인"
echo "   kubectl get applications -n argocd"
echo ""
echo "   # ArgoCD CLI로 확인"
echo "   argocd app list"
echo ""
echo "   # 수동 동기화"
echo "   argocd app sync serverful-study-dev"

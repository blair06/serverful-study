#!/bin/bash

# ArgoCD 시크릿 설정 스크립트
# 이 스크립트는 ArgoCD Image Updater를 위한 GitHub Personal Access Token을 설정합니다.

set -e

echo "🔐 ArgoCD 시크릿 설정을 시작합니다..."

# GitHub 사용자명 입력
read -p "GitHub 사용자명을 입력하세요: " GITHUB_USERNAME

# Personal Access Token 입력
echo "GitHub Personal Access Token을 입력하세요:"
echo "필요한 권한: read:packages, write:packages, repo (private repo인 경우)"
read -s GITHUB_TOKEN

echo ""
echo "📦 ArgoCD 네임스페이스 확인 중..."
kubectl get namespace argocd > /dev/null 2>&1 || {
    echo "❌ ArgoCD 네임스페이스가 존재하지 않습니다. 먼저 ArgoCD를 설치해주세요."
    echo "   ./scripts/install-argocd.sh 실행"
    exit 1
}

echo "🔑 GitHub Container Registry 토큰 Secret 생성 중..."
kubectl create secret generic ghcr-token \
  --from-literal=username="$GITHUB_USERNAME" \
  --from-literal=password="$GITHUB_TOKEN" \
  -n argocd \
  --dry-run=client -o yaml | kubectl apply -f -

echo "✅ Secret이 성공적으로 생성되었습니다!"

echo ""
echo "🔍 생성된 Secret 확인:"
kubectl get secret ghcr-token -n argocd

echo ""
echo "📋 다음 단계:"
echo "1. ArgoCD Image Updater 설치:"
echo "   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml"
echo ""
echo "2. Image Updater 설정 적용:"
echo "   kubectl apply -f argocd/image-updater-config.yaml"
echo ""
echo "3. Application 배포:"
echo "   kubectl apply -f argocd/app-dev-with-updater.yaml"
echo ""
echo "🎉 시크릿 설정이 완료되었습니다!"

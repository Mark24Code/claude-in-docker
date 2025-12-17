#!/bin/bash

# 构建和推送基础镜像脚本
# 使用方法: ./build-base-image.sh

set -e

# 默认使用 mark24code/claude-in-docker 作为镜像名称
DOCKERHUB_USERNAME=${1:-"mark24code"}
IMAGE_NAME="claude-in-docker"
TAG="latest"
FULL_IMAGE_NAME="${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${TAG}"

echo "========================================="
echo "构建 Claude Code 开发环境基础镜像"
echo "========================================="
echo "镜像名称: ${FULL_IMAGE_NAME}"
echo ""

# 构建基础镜像
echo "步骤 1/3: 构建基础镜像..."
cd "$(dirname "$0")"
docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile.base -t ${IMAGE_NAME}:${TAG} .
docker tag ${IMAGE_NAME}:${TAG} ${FULL_IMAGE_NAME}

echo ""
echo "✓ 基础镜像构建完成"
echo ""

# 询问是否登录 Docker Hub
read -p "是否需要登录 Docker Hub? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "步骤 2/3: 登录 Docker Hub..."
    docker login
fi

# 询问是否推送到 Docker Hub
echo ""
read -p "是否推送镜像到 Docker Hub? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "步骤 3/3: 推送镜像到 Docker Hub..."
    docker push ${FULL_IMAGE_NAME}
    echo ""
    echo "========================================="
    echo "✓ 镜像推送成功！"
    echo "========================================="
    echo ""
    echo "下一步："
    echo "1. 编辑 Dockerfile，将 BASE_IMAGE 参数修改为:"
    echo "   ARG BASE_IMAGE=${FULL_IMAGE_NAME}"
    echo ""
    echo "2. 或者在构建时指定:"
    echo "   docker build --build-arg BASE_IMAGE=${FULL_IMAGE_NAME} -f Dockerfile ."
    echo ""
    echo "3. 团队成员可以直接使用该基础镜像，无需重新构建"
    echo "========================================="
else
    echo ""
    echo "========================================="
    echo "镜像构建完成但未推送"
    echo "========================================="
    echo ""
    echo "本地镜像标签:"
    echo "  - ${IMAGE_NAME}:${TAG}"
    echo "  - ${FULL_IMAGE_NAME}"
    echo ""
    echo "如需推送，运行:"
    echo "  docker push ${FULL_IMAGE_NAME}"
    echo "========================================="
fi

echo ""
echo "基础镜像信息:"
docker images | grep -E "REPOSITORY|${IMAGE_NAME}"

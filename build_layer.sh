#!/bin/bash

# パスを解決
commonPath=$(realpath ./lambda/common)
requirementsPath=$(realpath ./requirements.txt)
distPath=$(realpath .)

# イメージがなければビルド
if [[ -z $(docker images -q lambdalayerbuilder:latest) ]]; then
  docker build -t lambdalayerbuilder:latest -f ./docker/Dockerfile ./docker
fi

# Dockerイメージが存在するかどうかをチェック
imageExists=$(docker image inspect lambdalayerbuilder:latest -f "{{.Id}}" 2>/dev/null)

if [[ -n "$imageExists" ]]; then
  # Lambda Layerをビルド
  docker run --rm \
    -v "${commonPath}:/source/common" \
    -v "${requirementsPath}:/source/requirements.txt" \
    -v "${distPath}:/dist" \
    -e "ZIP_FILE_NAME=lambda_layer.zip" \
    -e "PYTHON_VERSION=3.12" \
    lambdalayerbuilder:latest
  # Lambda関数をビルド
  sam build
fi

# 終了
read -p "Press Enter to continue..."

# パスを解決
$commonPath = (Resolve-Path ./lambda/common).Path
$requirementsPath = (Resolve-Path ./requirements.txt).Path
$distPath = (Resolve-Path .).Path

# イメージがなければビルド
if (-not (docker images -q "lambdalayerbuilder:latest")) {
  docker build -t lambdalayerbuilder:latest -f ./docker/Dockerfile ./docker
}

# Dockerイメージが存在するかどうかをチェック
$imageExists = docker image inspect lambdalayerbuilder:latest -f "{{.Id}}" 2>$null

if ($imageExists) {
  # Lambda Layerをビルド
  docker run --rm `
    -v "${commonPath}:/source/common" `
    -v "${requirementsPath}:/source/requirements.txt" `
    -v "${distPath}:/dist" `
    -e "ZIP_FILE_NAME=lambda_layer.zip" `
    -e "PYTHON_VERSION=3.12" `
    lambdalayerbuilder:latest
  # Lambda関数をビルド
  sam build
}

# 終了
Read-Host "Press Enter to continue..."

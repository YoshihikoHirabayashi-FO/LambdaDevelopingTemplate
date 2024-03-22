# このリポジトリは

Windows環境（またはその他の非Amazon Linux環境）でAWS Lambda + Pythonの開発環境を<br>
ローカル端末のみで構築するための課題と解決策をサンプル実装とともに提示するリポジトリです。

# 制限事項

- Windows環境で検証しているためshell scriptは`*.ps1`形式です。
  - mac/linux環境のため`*.sh`ファイルを添付していますがChatGPTに翻訳させたもので動作未検証です。
- `init.ps1`は`PowerShell 7`で正しく動作します。`PowerShell 5.1`では正しく動作しません。
  - `SecretManager`にSecretを登録する箇所で文字列中の`"`のエスケープ形式が異なるためです。

# 課題

非Amazon Linux環境でAWS Lambda + Pythonのローカル開発環境を、完全にローカル端末だけで構築するのが難しい

1. **Pythonライブラリを実行環境（Amazon Linux）環境用にビルドする必要がある**
  - 非Amazon Linux環境ではビルド環境を別途用意する必要がある

2. **Lambda以外のAWSサービスと連携する処理がある場合開発環境としてAWSを使用する必要がある**
  - 複数人で環境を共有する場合コンフリクトや環境汚染が発生する
    - 誰が何の目的で作ったかわからない、消していいかわからない残留物

3. **Lambdaを使用したWeb APIを実行するためにAPI Gatewayに相当するサーバ機能が必要**

# 解決策

1. **Dockerによるビルド環境**
  - Amazon Linuxの公式イメージを利用

2. **LocalStackの利用**
  - サードパーティー製のAWSエミュレータ

3. **AWS SAM CLIの利用**
  - Amazon製のLambda開発ツール
    - Lambda関数の実行環境
    - 簡易なAPI Gatewayのシミュレーション
    - AWS環境へのLambda関数のデプロイ

## LocalStackの特徴

- **良いところ**
  - 無料版がある
  - 使いやすい
    - Dockerコンテナを立ち上げるだけで使える
    - 利用方法はAWSの実環境と同じ
      - AWS CLIの接続先をLocalStackにして使う
    - AWS固有のサービスをローカル実行できる
      - S3やSecretsManagerなどがローカルで使用できる

- **悪いところ**
  - 有料版の料金は$35/monthから。この金額ならAWSの実環境を使うほうがマシ。
  - 有料版でないと使えない機能がある
    - 無償版ではLambdaの開発は実質不可能
      - LambdaLayerが使えない（有償機能）
      - Lambda関数のサイズが大きくなるとタイムアウトでまともに動かない
        - ライブラリ一ついれたらアウト

# 開発環境の構成

- **開発環境**
  - 適当なIDEを使う（なんでもいい）

- **ビルド環境**
  - Docker
    - Amazon Linuxの公式イメージをベースとしたカスタムイメージ
      - 以下の処理を自動化する
        - ホストのフォルダをコンテナにマウント
        - pythonのlibraryをビルド
        - Lambda Layerをzipに圧縮
        - Lambda Layerをホストに書き出し
  - AWS SAM
    - AWS環境への成果物のデプロイ
    - ※AWS環境へのデプロイ方法はぐぐれば出てくるのでこのリポジトリでは説明しません

- **実行環境**
  - AWS SAM
    - `sam local start-api`コマンドでLambdaとAPI Gatewayのローカル実行ができる

# 初期設定

1. **ツールのインストール**
  - AWS CLI
  - AWS SAM
  - Python 3.12
    - PyEnvを使うのが便利
  - Docker Desktop

2. **Dockerの設定**
  - LocalStack Dockerコンテナの作成 
    - `docker-compose up -d`
      - `./init.ps1`に記載
  - ビルド用Dockerイメージの作成
    - `docker build -t lambdalayerbuilder:latest -f ./docker/Dockerfile ./docker`
      - `./build_layer.ps1`に記載

# リポジトリの構成

```
.
├── README.md
├── build_layer.ps1
├── build_layer.sh
├── docker
│   ├── Dockerfile
│   └── entrypoint.sh
├── docker-compose.yml
├── init.ps1
├── init.sh
├── lambda
│   ├── common
│   │   └── utils.py
│   └── functions
│       ├── hello_world.py
│       ├── s3read.py
│       ├── s3write.py
│       └── secrets.py
├── requirements.txt
└── template.yml
```

### サンプル実装

```
.
├── init.ps1
├── init.sh
├── lambda
│   ├── common
│   │   └── utils.py
│   └── functions
│       ├── hello_world.py
│       ├── s3read.py
│       ├── s3write.py
│       └── secrets.py
└── requirements.txt
```

- `init.ps1`(`init.sh`)
  - 初期設定スクリプト
  - サンプルコード用のSecretsManager設定
  - サンプルコード用のS3バケット設定

- `requirements.txt`
  - サンプルコード用のpythonライブラリ
  - Lambda Layerに含める

- `lambda/common/*`
  - Lambda Layerに共通部品を実装するサンプル
  - Lambda Layerに含める

- `lambda/functions/*`
  - `hello_world.py`
    - Hello World
  - `s3read.py`
    - S3からリソースを取得するサンプル
  - `s3write.py`
    - S3にリソースを書き込むサンプル
  - `secrets.py`
    - SecretsManagerからSecretsを取得するサンプル


### ビルド方法

- `build_layer.ps1`を実行する

```
.
├── build_layer.ps1
├── build_layer.sh
└── docker
    ├── Dockerfile
    └── entrypoint.sh
```

`build_layer.ps1`(`build_layer.sh`)
  - `./requirements.txt`使用しライブラリをビルド
  - `./lambda/common`フォルダ配下のソースコードを読み取り
  - ライブラリと共通部品のソースコードを`lambda_layer.zip`にまとめる

### 実行方法

- AWS SAMでローカル実行
```
sam build
docker-compose up -d
sam local start-api --warm-containers EAGER
```

- サンプル実装のURL
  - http://localhost:3000/api/hello_world?param1=hello&param2=world
    - Hello World
  - http://localhost:3000/api/s3write?content=test
    - `content`パラメータの内容をS3に書き込む
  - http://localhost:3000/api/s3read
    - `s3write`で書き込んだ内容をS3から読み出す
  - http://localhost:3000/api/secrets
    - SecretsManagerからsecretを取り出す

```
.
└── template.yml
```

- `./template.yml`
  - AWS SAMの設定ファイル




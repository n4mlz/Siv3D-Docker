## Siv3D テンプレート

このリポジトリは、再利用可能な base image を中心にした Linux 向け Siv3D テンプレートです。

### できること

- ルート直下の CMake プロジェクトでゲームコードを置ける
- `ghcr.io/n4mlz/siv3d-docker-base` に公開される Siv3D base image を使える
- devcontainer で Siv3D の再ビルドなしにすぐ開発を始められる
- `docker compose` でホストの GUI に接続して Linux 上で実行できる
- `ccache` と build 用 volume で再ビルドを高速化できる
- GitHub Actions から base image を自動公開できる

### 使い方

#### 1. devcontainer で開く

VS Code などで devcontainer を開くと、公開済みの base image をそのまま利用します。

#### 2. compose で起動する

```bash
docker compose up -d
docker compose exec siv3d-app bash
```

#### 3. プロジェクトをビルドする

コンテナ内またはローカルの Linux 環境で、リポジトリのルートからビルドします。

```bash
cmake -S . -B build -GNinja -DCMAKE_BUILD_TYPE=Debug
cmake --build build
```

#### 4. 実行する

```bash
./build/Siv3DTemplate
```

### 主な feature

- **Siv3D base image の分離**: 重い Siv3D ビルドを `docker/base/Dockerfile` に集約
- **高速な再ビルド**: `ccache` と named volume でゲーム側の再ビルドを短縮
- **Linux GUI 対応**: X11 をホストにバイパスして描画可能
- **devcontainer 対応**: そのまま開いて開発を始められる
- **GitHub Actions 対応**: `main` への push などで GHCR に公開
- **テンプレート向け構成**: `src/Main.cpp` だけを触ればゲームの起点になる

### GitHub Actions

`docker/base/Dockerfile` から base image をビルドし、`.github/workflows/publish-base-image.yml` から GHCR に公開します。

`latest` と commit/tag ベースのタグを付けるので、devcontainer と compose の両方で安定して利用できます。

### ファイル構成

- `CMakeLists.txt`: ルートの CMake 定義
- `src/Main.cpp`: グラフィカルな最小サンプル
- `docker/base/Dockerfile`: Siv3D base image のビルド定義
- `.devcontainer/devcontainer.json`: devcontainer 設定
- `compose.yml`: ローカル実行用の compose 定義
- `.github/workflows/publish-base-image.yml`: GHCR への公開 workflow

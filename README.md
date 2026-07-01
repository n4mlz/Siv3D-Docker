## Siv3D Base Image

このリポジトリは、Siv3D 用の base image をビルドして GHCR に公開するためのものです。

### 責務

- Siv3D 本体のビルドとインストール
- Linux 用の開発依存パッケージの管理
- `ccache` と BuildKit キャッシュを使った高速化
- GitHub Actions から `ghcr.io/n4mlz/siv3d-docker-base` への公開

### できること

- Siv3D を何度もローカルでビルドし直さずに済む
- template 側の devcontainer / compose から共通 image を使える
- マルチステージビルドで最終 image を小さく保てる
- Linux GUI や開発依存を image 側に寄せられる

### 使い方

#### ローカルで image をビルドする

```bash
docker buildx build -f docker/base/Dockerfile --load .
```

#### GHCR に公開する

`.github/workflows/publish-base-image.yml` が `main` への push や tag push で自動公開します。

#### 利用側テンプレート

この base image を利用するテンプレートは、別リポジトリの `/home/noname/me/workspace/personal/siv3d-template` に分離しています。

### 主な feature

- **Siv3D base image の集中管理**: heavy な build をこの repo に集約
- **キャッシュ対応**: BuildKit cache と `ccache` を活用
- **小さい最終 image**: multi-stage で build tree を持ち込まない
- **GHCR 公開**: GitHub Actions で継続的に配布

### ファイル構成

- `docker/base/Dockerfile`: Siv3D base image の定義
- `.github/workflows/publish-base-image.yml`: GHCR への publish workflow
- `.dockerignore`: Docker build context の整理

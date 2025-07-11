# フロントエンド設計書

## 1. 概要

本ドキュメントは、「予実管理AIアシスタントアプリ」のフロントエンドアーキテクチャとコンポーネント設計について定義する。

## 2. アーキテクチャ & 使用ライブラリ

- **フレームワーク**: Vue.js 3 (Composition APIベース)
- **テンプレートエンジン**: `Pug`
- **CSSプリプロセッサ**: `Sass (SCSS記法)`
- **UIライブラリ**: `bootstrap-vue-next`
- **ルーティング**: `vue-router`
- **HTTPクライアント**: Axios
- **状態管理**: Pinia
- **日付操作**: `date-fns`
- **グラフ描画**: `vue-chartjs`
- **Markdownパーサー**: `marked`
- **ビルドツール**: Vite

## 3. API連携設計

バックエンドAPIとの連携は、セキュリティと保守性を考慮して以下の通り設計する。

### 3.1. APIクライアント

- `src/api/client.js` (または `src/plugins/axios.js`) にAxiosのカスタムインスタンスを作成し、一元管理する。
- **共通設定**:
    - `baseURL`: 環境変数 (`VITE_API_BASE_URL`) からAPIのベースURLを設定する。
    - `withCredentials: true`: オリジン間リクエストでクッキー（セッションIDなど）を自動的に送受信するために必須。
    - `headers`: リクエストヘッダーの共通設定（`Content-Type`など）。
- **CSRFトークン連携**:
    1. アプリケーション初期化時に、バックエンドの専用エンドポイント (`/api/v1/csrf_token`) からCSRFトークンを取得する。
    2. 取得したトークンをAxiosインスタンスのデフォルトヘッダー (`X-CSRF-Token`) に設定する。
    3. これにより、以降の全てのPOST, PUT, DELETEリクエストでトークンが自動的に送信される。

### 3.2. 環境変数

- プロジェクトルートに `.env` ファイルを配置し、Viteの機能を使って環境変数を管理する。
- `VITE_API_BASE_URL`: 開発環境では `http://localhost:3000/api/v1`、本番環境では `/api/v1` などを設定。

## 4. ディレクトリ構成

```
src/
├── api/
│   ├── client.js      # Axiosカスタムインスタンス
│   ├── auth.js        # 認証関連API
│   └── ...            # 他のリソースAPI
├── assets/
├── components/
├── composables/
├── router/
├── stores/
├── views/
├── App.vue
└── main.js          # アプリケーションエントリーポイント
```

## 5. 状態管理 (Pinia)

機能ごとにストアを分割して管理する。

- **`auth.js`**: ユーザーの認証情報、ログイン状態を管理。
- **`calendar.js`**: 表示中の日付、Googleカレンダーの予定データ、実績データを管理。
- **`ui.js`**: モーダルの表示状態、ローディング状態など、UIに関する状態を管理。
- **`categories.js`**: ユーザーが作成したカテゴリの一覧を管理。
- **`weeklyGoals.js`**: 週次目標、およびその進捗データを管理。

## 6. ルーティング (Vue Router)

- `/`: `HomeView` (未認証時) / `MainView` (認証時) - `beforeEnter`ガードで振り分け
- `/auth/callback`: `AuthCallback.vue` (Google認証からのコールバック処理)
- `/dashboard`: `DashboardView` (認証が必要)
- `/weekly-goals`: `WeeklyReviewView` (認証が必要)

## 7. 認証フロー (PKCE)

- 認証が必要なルートには `beforeEnter` ナビゲーションガードを設定し、Piniaの `auth` ストアをチェックして未認証なら `/` にリダイレクトする。
- ログイン処理の詳細は[ユーザー認証設計書](./01_user_authentication.md)を参照。
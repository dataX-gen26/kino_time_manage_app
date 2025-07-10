# バックエンド設計書

## 1. 概要

本ドキュメントは、「予実管理AIアシスタントアプリ」のバックエンドアーキテクチャとAPI設計について定義する。バックエンドはAPIとして機能し、フロントエンドのVue.jsアプリケーションと連携する。

## 2. アーキテクチャ & 使用ライブラリ

- **フレームワーク**: Ruby on Rails 7 (APIモード)
- **データベース**: MySQL
- **Google認証**: `omniauth-google-oauth2`
- **CORS対応**: `rack-cors`
- **認可 (アクセス制御)**: `Pundit`
- **JSONシリアライザ**: `active_model_serializers`
- **外部APIクライアント**: `httparty` (Gemini API連携用)
- **API仕様記述**: `rswag`

## 3. API基本設計

- **エンドポイント**: 全てのエンドポイントは `/api/v1/` プレフィックスを持つ。
- **データ形式**: リクエスト/レスポンスボディはJSON形式とする。
- **エラーハンドリング**: 標準的なHTTPステータスコードでエラーを表現する。

### 3.1. セキュリティ設計

#### 3.1.1. CORS (Cross-Origin Resource Sharing)

- `config/initializers/cors.rb` にて `rack-cors` の設定を行う。
- 開発環境ではフロントエンドの開発サーバーオリジン（例: `http://localhost:5173`）からのリクエストを許可する。
- 本番環境ではデプロイ先のフロントエンドのオリジンを許可する。
- `credentials: true` を設定し、フロントエンドからのクッキー送受信を許可する。

#### 3.1.2. CSRF (Cross-Site Request Forgery) 対策

- Rails標準の `protect_from_forgery with: :exception` を `ApplicationController` で有効にする。
- SPAにCSRFトークンを渡すための専用エンドポイントを設ける。
    - `GET /api/v1/csrf_token`: `{ "csrf_token": "..." }` の形式で現在のCSRFトークンを返す。
- フロントエンドは、このトークンを `X-CSRF-Token` ヘッダーに含めてリクエストを送信する。

### 3.2. 認証

- [ユーザー認証設計書](./01_user_authentication.md) に記載のPKCEフローに基づき、セッションベースの認証を実装する。

## 4. APIエンドポイント一覧

- **認証**: 
    - `POST /api/v1/auth/google/callback`
    - `DELETE /api/v1/auth/logout`
    - `GET /api/v1/sessions/check`
- **CSRF**: 
    - `GET /api/v1/csrf_token`
- **週次目標管理**: 
    - `GET, POST /api/v1/weekly_goals`
    - `GET, PUT, DELETE /api/v1/weekly_goals/:id`
    - `GET, POST /api/v1/weekly_goals/:id/progresses`
- (その他リソースAPI...)

## 5. ディレクトリ構成 (Rails APIモード標準)

```
app/
├── controllers/
│   └── api/
│       └── v1/
│           ├── auth_controller.rb
│           ├── csrf_tokens_controller.rb # CSRFトークン配信用
│           └── ...
├── models/
└── services/
config/
├── initializers/
│   └── cors.rb # CORS設定
└── routes.rb
```
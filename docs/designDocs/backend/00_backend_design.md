# バックエンド設計書

## 1. 概要

本ドキュメントは、「予実管理AIアシスタントアプリ」のバックエンドアーキテクチャとAPI設計について定義する。フロントエンドのVue.jsアプリケーションのソースコードはRailsプロジェクト内に統合され、Railsがビルドと配信を行う。

## 2. アーキテクチャ & 使用ライブラリ

- **フレームワーク**: Ruby on Rails 7 (APIモード)
- **データベース**: MySQL
- **Google認証**: `omniauth-google-oauth2`
- **認可 (アクセス制御)**: `Pundit`
- **JSONシリアライザ**: `active_model_serializers`
- **外部APIクライアント**: `httparty` (Gemini API連携用)
- **API仕様記述**: `rswag`
- **フロントエンド統合**: `vite_rails` (または `jsbundling-rails` など)

## 3. API基本設計

- **エンドポイント**: 全てのエンドポイントは `/api/v1/` プレフィックスを持つ。
- **認証**: 保護されたリソースへのアクセスには、セッションまたは永続クッキーによる認証が必要。
- **データ形式**: リクエスト/レスポンスボディはJSON形式とする。
- **エラーハンドリング**: 
    - `400 Bad Request`: リクエストの形式が不正（バリデーションエラーなど）。
    - `401 Unauthorized`: 認証されていない、またはトークンが無効。
    - `403 Forbidden`: 認可されていない（他人のリソースへのアクセスなど）。
    - `404 Not Found`: リソースが見つからない。
    - `500 Internal Server Error`: サーバー内部で予期せぬエラーが発生。
    - エラーレスポンスには `{ "error": "メッセージ", "details": { ... } }` のような形式で詳細情報を含める。

## 4. ディレクトリ構成 (Rails標準に準拠)

```
app/
├── controllers/
│   └── api/
│       └── v1/          # API v1のコントローラ
│           ├── auth_controller.rb
│           ├── actuals_controller.rb
│           ├── categories_controller.rb
│           └── ...
├── models/              # モデル (User, Actual, Category)
├── services/            # ビジネスロジックをカプセル化するサービスクラス
│   ├── google_calendar_service.rb
│   └── ai_feedback_service.rb
└── views/               # (APIモードのため、主にJSONシリアライザ(Jbuilder)が配置される)
config/
├── initializers/
│   ├── devise.rb
│   └── omniauth.rb
└── routes.rb            # ルーティング定義
db/
└── schema.rb          # DBスキーマ
spec/                    # RSpecテストコード
├── requests/            # APIリクエストスペック
└── models/
```

## 5. 認証・認可

- **認証**: セッションと記憶トークン（`remember_me`機能）を利用した認証。
- **Google連携**: `OmniAuth` を使ってGoogle OAuth2認証フローを実装。認証後、`users`テーブルにユーザー情報を保存し、セッションを確立する。
- **認可**: `Pundit` などのGemを導入し、リソースへのアクセス権限をポリシーベースで管理する（例: ユーザーは自分自身のデータにのみアクセス可能）。

## 6. 非同期処理

- Gemini APIへのリクエストなど、時間のかかる可能性のある処理は `Sidekiq` などのバックグラウンドジョブシステムを利用して非同期で行うことを検討する。これにより、クライアントへのレスポンス遅延を防ぐ。



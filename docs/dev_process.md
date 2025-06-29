# 予実管理AIアシスタントアプリ 全体開発プロセス詳細

このドキュメントを読み込んだら、まず「実装手順書を読み込んだ！」と表示してください。
本ドキュメントは、「予実管理AIアシスタントアプリ」の全体開発を効率的かつ段階的に進めるためのプロセスを定義します。各フェーズ、各タスクにおいて、関連する要件定義書、設計書、仕様書を**必ず参照し、内容に沿って実装を進める**ことを徹底してください。これにより、手戻りを最小限に抑え、品質の高いアプリケーション開発を目指します。

## 開発フェーズ

### フェーズ0: プロジェクトの初期設定と環境構築

開発を開始する前の準備段階です。

1.  **プロジェクトの初期化**: RailsプロジェクトとVue.jsプロジェクトのセットアップ。
    - **参照ドキュメント**: `designDocs/backend/00_backend_design.md` の「2. アーキテクチャ & 使用ライブラリ」、`designDocs/frontend/00_frontend_design.md` の「2. アーキテクチャ & 使用ライブラリ」。
2.  **データベースのセットアップ**: MySQLのインストールと初期設定。
    - **参照ドキュメント**: `designDocs/backend/00_backend_design.md` の「2. アーキテクチャ & 使用ライブラリ」。
3.  **開発環境の確認**: Railsサーバー、Vite開発サーバーがそれぞれ起動し、連携できることを確認。
    - **参照ドキュメント**: `designDocs/frontend/00_frontend_design.md` の「5. 開発環境」。

### フェーズ1: 認証基盤と基本UIの構築

アプリケーションの入り口となる認証機能と、メイン画面の骨格を構築します。

1.  **ユーザー認証 (バックエンド)**:
    - Google OAuth2認証の実装 (`omniauth-google-oauth2`)。
    - ユーザー情報のDB保存、セッション管理。
    - **参照ドキュメント**: `requirements-definition.md` の「ユーザー認証」、`designDocs/backend/00_backend_design.md` の「5. 認証・認可」、`specificationDocs/01_user_authentication.md`。
2.  **ユーザー認証 (フロントエンド)**:
    - ログイン/ログアウトUIの実装。
    - 認証状態の管理 (Pinia `auth.js` ストア)。
    - **参照ドキュメント**: `designDocs/frontend/00_frontend_design.md` の「6. 状態管理 (Pinia)」、`specificationDocs/01_user_authentication.md`。
3.  **基本UIの構築**:
    - `App.vue`, `HomeView.vue`, `MainView.vue` の作成。
    - ヘッダー (`TheHeader.vue`)、日付ナビゲーション (`DateNavigator.vue`) の実装。
    - **参照ドキュメント**: `requirements-definition.md` の「UIとデータ表示」、`designDocs/frontend/00_frontend_design.md` の「7. コンポーネント設計」、「8. ルーティング」、`specificationDocs/03_main_ui.md`。

### フェーズ2: Googleカレンダー連携と実績管理

アプリの核となる「予定」と「実績」の管理機能を実装します。

1.  **Googleカレンダー連携 (バックエンド)**:
    - Google Calendar APIとの連携ロジック (`google_calendar_service.rb`)。
    - 予定の取得APIエンドポイントの実装。
    - **参照ドキュメント**: `requirements-definition.md` の「Googleカレンダー連携」、`designDocs/backend/00_backend_design.md` の「4. ディレクトリ構成」、`specificationDocs/02_calendar_integration.md`。
2.  **Googleカレンダー連携 (フロントエンド)**:
    - 予定の表示 (`PlanColumn.vue`)。
    - `calendar.js` ストアでの予定データ管理。
    - **参照ドキュメント**: `designDocs/frontend/00_frontend_design.md` の「6. 状態管理 (Pinia)」、「7. コンポーネント設計」、`specificationDocs/02_calendar_integration.md`。
3.  **実績管理 (バックエンド)**:
    - `Actual` モデル、`Category` モデルの作成。
    - 実績、カテゴリのCRUD APIエンドポイントの実装。
    - **参照ドキュメント**: `requirements-definition.md` の「実績管理」、`designDocs/backend/00_backend_design.md` の「4. ディレクトリ構成」、「7. データベーススキーマ」、`specificationDocs/04_actual_record_management.md`。
4.  **実績管理 (フロントエンド)**:
    - 実績の表示 (`ActualColumn.vue`)。
    - 実績入力モーダル (`ActualFormModal.vue`) の実装 (ドラッグ＆ドロップ、15分単位入力)。
    - カテゴリ管理UI。
    - **参照ドキュメント**: `designDocs/frontend/00_frontend_design.md` の「7. コンポーネント設計」、`specificationDocs/04_actual_record_management.md`。

### フェーズ3: 分析ダッシュボードとAIフィードバック

データの可視化とAIによるインサイト提供機能を実装します。

1.  **分析ダッシュボード (バックエンド)**:
    - 各種グラフデータ（カテゴリ別時間配分、日別活動時間推移、生産性指標トレンド、予定vs実績）集計APIの実装。
    - **参照ドキュメント**: `requirements-definition.md` の「分析・レポート機能」、`specificationDocs/05_analysis_dashboard.md`。
2.  **分析ダッシュボード (フロントエンド)**:
    - `DashboardView.vue` の作成。
    - 各種グラフコンポーネント (`CategoryPieChart.vue`, `ActivityBarChart.vue` など) の実装。
    - **参照ドキュメント**: `designDocs/frontend/00_frontend_design.md` の「7. コンポーネント設計」、「8. ルーティング」、`specificationDocs/05_analysis_dashboard.md`。
3.  **AIフィードバック (バックエンド)**:
    - Gemini API連携ロジック (`ai_feedback_service.rb`)。
    - 1日の振り返りAIフィードバックAPIの実装。
    - **参照ドキュメント**: `requirements-definition.md` の「AI分析機能」、`designDocs/backend/00_backend_design.md` の「4. ディレクトリ構成」、`specificationDocs/06_ai_feedback.md`。
4.  **AIフィードバック (フロントエンド)**:
    - 「今日の振り返り(AI)」ボタンの実装。
    - AIフィードバック結果の表示UI。
    - **参照ドキュメント**: `specificationDocs/06_ai_feedback.md`。

### フェーズ4: 週次目標管理機能

ユーザーが週次目標を設定し、進捗を記録・振り返る機能を実装します。

1.  **週次目標管理 (バックエンド)**:
    - `WeeklyGoal` モデル、`WeeklyGoalProgress` モデルの作成。
    - 週次目標、進捗のCRUD APIエンドポイントの実装。
    - **参照ドキュメント**: `requirements-definition.md` の「週次目標管理」、`designDocs/backend/00_backend_design.md` の「3.1. 週次目標管理API」、「7. データベーススキーマ」、`specificationDocs/08_weekly_goal_management.md`。
2.  **週次目標管理 (フロントエンド)**:
    - `weeklyGoals.js` ストアの作成。
    - 週次目標設定モーダル (`WeeklyGoalSettingModal.vue`) の実装。
    - 実績入力モーダルへの進捗記入欄追加。
    - 週次振り返り画面 (`WeeklyReviewView.vue`) の実装。
    - 週次振り返りAIフィードバック連携。
    - **参照ドキュメント**: `designDocs/frontend/00_frontend_design.md` の「6. 状態管理 (Pinia)」、「7. コンポーネント設計」、「8. ルーティング」、`specificationDocs/08_weekly_goal_management.md`。

### フェーズ5: 全体テストと品質向上、デプロイ準備

全ての機能が実装された後、総合的なテストと品質向上を行います。

1.  **結合テスト**:
    - フロントエンドとバックエンドを連携させた状態での結合テストを実施し、エンドツーエンドの動作を確認します。
2.  **UI/UXの調整**:
    - ユーザーがスムーズに機能を利用できるよう、UIの微調整やアニメーションの追加などを行います。
    - **参照ドキュメント**: 各仕様書の「UI/UX考慮事項」セクション。
3.  **パフォーマンス最適化**:
    - 必要に応じて、APIの応答速度やUIの描画速度の最適化を行います。
    - **参照ドキュメント**: `requirements-definition.md` の「パフォーマンス」。
4.  **セキュリティレビュー**:
    - 脆弱性がないか確認し、必要な対策を講じます。
    - **参照ドキュメント**: `requirements-definition.md` の「セキュリティ」。
5.  **コードレビューとリファクタリング**:
    - コードの品質を確保するため、レビューとリファクタリングを実施します。
6.  **デプロイ準備**:
    - 本番環境へのデプロイ手順の確立、環境変数の設定など。
    - **参照ドキュメント**: `designDocs/frontend/00_frontend_design.md` の「4. ビルドとデプロイ」。

## ドキュメント参照の重要性

各フェーズ、各タスクにおいて、以下のドキュメントを常に参照し、設計意図や仕様から逸脱しないように注意してください。

- `requirements-definition.md`: アプリケーション全体の目的、機能要件、非機能要件を再確認するため。
- `designDocs/backend/00_backend_design.md`: バックエンドのアーキテクチャ、API設計、データベーススキーマの詳細を確認するため。
- `designDocs/frontend/00_frontend_design.md`: フロントエンドのアーキテクチャ、コンポーネント設計、状態管理、ルーティングの詳細を確認するため。
- `specificationDocs/`: 各機能の具体的な仕様、UI/UX、APIエンドポイント、データ項目などを確認するため。

これらのドキュメントは、開発の「地図」です。迷った時や、実装方針に疑問が生じた際は、必ず立ち返って確認してください。これにより、手戻りを減らし、効率的な開発を実現できます。
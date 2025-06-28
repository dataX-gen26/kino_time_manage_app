# 設計書: 05 AIによるフィードバック機能

## 1. フロントエンド設計 (Vue.js)

### 1.1. 関連コンポーネント

- **`views/MainView.vue`**: 「今日の振り返り(AI)」ボタンを配置。
- **`components/specific/ai/FeedbackModal.vue`**: AIからのフィードバック結果を表示するモーダル。
    - ローディングスピナーと、整形されたマークダウンテキストを表示する。

### 1.2. 状態管理 (Pinia: `stores/ai.js`)

- **State**:
    - `feedback: string | null`: AIからのフィードバックテキスト（Markdown形式）。
    - `isLoading: boolean`: APIリクエスト中のローディング状態。
- **Actions**:
    - `fetchFeedback(date, plans, actuals)`: 指定された日の予定と実績データをバックエンドに送信し、フィードバックを取得する。
        1. `isLoading` を `true` に設定。
        2. 予定と実績データを簡潔な形式に整形。
        3. バックエンドの `/api/v1/ai/daily_review` にPOSTリクエスト。
        4. 成功したら `feedback` ステートを更新。
        5. 最後に `isLoading` を `false` に設定。

### 1.3. 表示

- `FeedbackModal` では、取得したMarkdownテキストを `marked` などのライブラリを使ってHTMLに変換して表示する。

## 2. バックエンド設計 (Ruby on Rails)

### 2.1. 関連ライブラリ

- `ruby-openai` または `google-cloud-ai_platform` など、利用するLLMに応じたGem。

### 2.2. APIエンドポイント

- **`POST /api/v1/ai/daily_review`**
    - **コントローラ**: `Api::V1::AiController#daily_review`
    - **パラメータ**: `{ plans: [...], actuals: [...] }`
    - **処理フロー**:
        1. リクエストボディから予定と実績のデータを受け取る。
        2. `AiFeedbackService.new(plans, actuals).generate_feedback` を呼び出す。
        3. サービスから返されたテキストをJSONでレンダリングする。
        4. API呼び出しでエラーが発生した場合は、`500 Internal Server Error` を返す。

### 2.3. サービスクラス (`services/ai_feedback_service.rb`)

- **目的**: Gemini APIとの通信とプロンプト生成ロジックをカプセル化する。
- **`initialize(plans, actuals)`**: コンストラクタでデータを受け取る。
- **`generate_feedback`**: 
    1. `build_prompt` メソッドを呼び出し、APIに送信するプロンプトを組み立てる。
    2. `initialize_client` メソッドでAPIクライアントを初期化。（APIキーは `Rails.application.credentials` から読み込む）
    3. APIクライアントにプロンプトを送信し、レスポンスを受け取る。
    4. レスポンスのテキスト部分を抽出し、返す。
- **`build_prompt` (private)**:
    - 仕様書で定義した役割、コンテキスト、データ、指示、出力形式を元に、精度の高いプロンプト文字列を生成するロジックを記述。

### 2.4. 非同期処理

- Gemini APIからのレスポンスには数秒かかる可能性があるため、この処理は非同期で行うのが望ましい。
- **実装案**: 
    1. コントローラはリクエストを受け付けたら、`AiFeedbackJob.perform_later(user, plans, actuals)` のようにSidekiqジョブをキューに入れる。
    2. ジョブIDなどを即座にフロントエンドに返す。
    3. フロントエンドは、ジョブIDを使って結果をポーリングするか、Action Cable（WebSocket）で結果がプッシュされるのを待つ。
    4. ジョブはバックグラウンドでAPI通信を行い、完了したら結果をDBに一時的に保存するか、WebSocketでクライアントに直接送信する。


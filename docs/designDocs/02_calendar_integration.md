# 設計書: 02 Googleカレンダー連携機能

## 1. フロントエンド設計 (Vue.js)

### 1.1. 関連コンポーネント

- **`views/MainView.vue`**: メイン画面の親コンポーネント。日付が変更されたらカレンダーデータ取得のトリガーとなる。
- **`components/specific/PlanColumn.vue`**: 取得した予定データを表示するコンポーネント。
- **`composables/useCalendar.js`**: カレンダー関連のロジックをまとめたコンポーザブル。

### 1.2. 状態管理 (Pinia: `stores/calendar.js`)

- **State**:
    - `currentDate: Date`: 現在表示中の日付。
    - `events: Array`: Googleカレンダーから取得した予定の配列。
    - `isLoading: boolean`: データ取得中のローディング状態。
- **Actions**:
    - `fetchEvents(date)`: 指定された日付の予定をバックエンドから取得するアクション。
        1. `isLoading` を `true` に設定。
        2. `api/calendar.js` の `getEvents(date)` を呼び出す。
        3. 成功したら `events` ステートを更新。
        4. 最後に `isLoading` を `false` に設定。
    - `changeDate(newDate)`: `currentDate` を更新し、`fetchEvents` をトリガーする。

### 1.3. APIクライアント (`api/calendar.js`)

- `axios` インスタンスを利用。
- `getEvents(date)`: バックエンドの `/api/v1/calendar/events` にGETリクエストを送信する関数を定義。

## 2. バックエンド設計 (Ruby on Rails)

### 2.1. 関連ライブラリ

- `google-api-client`: Google APIにアクセスするための公式ライブラリ。

### 2.2. APIエンドポイント

- **`GET /api/v1/calendar/events`**
    - **コントローラ**: `Api::V1::CalendarController#events`
    - **認証**: `devise_token_auth` による認証が必須。
    - **パラメータ**: `params[:date]` (YYYY-MM-DD形式)
    - **処理フロー**:
        1. `current_user` (認証済みユーザー) を取得。
        2. `params[:date]` をパースして、対象日の開始時刻 (`time_min`) と終了時刻 (`time_max`) をUTCで生成。
        3. `GoogleCalendarService.new(current_user).fetch_events(time_min, time_max)` を呼び出し、イベントデータを取得。
        4. 取得したデータをフロントエンドが扱いやすいJSON形式に整形してレンダリングする。
        5. `Google::Auth::TokenRefreshError` などの例外を補足し、適切なエラーレスポンスを返す。

### 2.3. サービスクラス (`services/google_calendar_service.rb`)

- **目的**: Google Calendar APIとのやり取りに関するロジックをカプセル化する。
- **`initialize(user)`**: コンストラクタでユーザーオブジェクトを受け取る。
- **`fetch_events(time_min, time_max)`**: 
    1. `Signet::OAuth2::Client` を初期化。クライアントID/シークレット、ユーザーのアクセストークン/リフレッシュトークンを設定。
    2. トークンが期限切れなら、`client.refresh!` でトークンを更新し、新しいトークンを `users` テーブルに保存する。
    3. `Google::Apis::CalendarV3::CalendarService` を初期化。
    4. `list_events` メソッドを呼び出し、指定期間のイベントを取得。
    5. 必要な情報（タイトル, 開始/終了時刻など）を抽出・整形して返す。

### 2.4. セキュリティ

- ユーザーのアクセストークンとリフレッシュトークンは、DBに保存する前に `Rails.application.credentials` を使って暗号化する。

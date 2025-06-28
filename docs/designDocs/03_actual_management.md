# 設計書: 03 メイン画面UIと実績管理

## 1. フロントエンド設計 (Vue.js)

### 1.1. 関連コンポーネント

- **`views/MainView.vue`**: 全体を統括。`DateNavigator` と `CalendarGrid` を配置。
- **`components/layout/DateNavigator.vue`**: 日付移動（前日、翌日、今日、日付ピッカー）のUIとロジック。
    - `calendarStore.changeDate()` アクションを呼び出す。
- **`components/specific/CalendarGrid.vue`**: 時間軸と、`PlanColumn` `ActualColumn` を並べて表示。
- **`components/specific/ActualColumn.vue`**: 実績列。
    - 実績ブロック (`ActualBlock.vue`) を `v-for` で表示。
    - ドラッグによる新規実績作成のイベント（`@mousedown`, `@mousemove`, `@mouseup`）をハンドリング。
- **`components/specific/ActualBlock.vue`**: 個々の実績ブロック。
    - `@click` で編集モーダルを開く。
- **`components/specific/ActualFormModal.vue`**: 実績の新規作成・編集フォームを持つモーダル。
    - `v-model` でフォームの各入力とデータをバインド。
    - カテゴリ選択は `categoryStore` から取得したリストを使用。
    - 「保存」ボタンクリックで `actualsStore.createActual()` または `updateActual()` を呼び出す。

### 1.2. 状態管理 (Pinia)

- **`stores/calendar.js`**:
    - `actuals: Array`: 表示中の日付の実績データを保持。
    - `fetchActuals(date)`: バックエンドから実績データを取得するアクション。
- **`stores/categories.js`**:
    - `categories: Array`: 全カテゴリのリスト。
    - `fetchCategories()`: バックエンドからカテゴリを取得するアクション。
- **`stores/actuals.js` (新規)**:
    - `createActual(data)`, `updateActual(id, data)`, `deleteActual(id)`: バックエンドAPIを呼び出し、成功したら `calendar.js` の実績データを更新するアクション。

### 1.3. シーケンス（実績作成）

1.  ユーザーが `ActualColumn` をドラッグ&ドロップ。
2.  ドロップ時に、開始時刻と終了時刻を計算し、`ActualFormModal` を表示。
3.  ユーザーがモーダルで内容とカテゴリを入力し、「保存」をクリック。
4.  `actualsStore.createActual()` が呼ばれ、バックエンドに `POST /api/v1/actuals` リクエストを送信。
5.  APIが成功を返したら、`calendarStore.fetchActuals()` を再実行して画面を更新する。

## 2. バックエンド設計 (Ruby on Rails)

### 2.1. APIエンドポイント

- **`GET /api/v1/actuals`**: 指定日の実績一覧を取得。
    - `params[:date]` を受け取る。
    - `current_user.actuals.where(start_time: date.all_day)` のようにして取得。
- **`POST /api/v1/actuals`**: 新規実績を作成。
    - `params` で実績の内容、時刻、カテゴリIDなどを受け取る。
    - `current_user.actuals.build(actual_params)` で作成。
- **`PUT /api/v1/actuals/:id`**: 実績を更新。
    - `Pundit` などで、`current_user` が実績の所有者であることを確認。
- **`DELETE /api/v1/actuals/:id`**: 実績を削除。
    - 所有者であることを確認。
- **`GET /api/v1/categories`**: カテゴリ一覧を取得。
- **`POST /api/v1/categories`**: カテゴリを作成。
- `PUT /api/v1/categories/:id`, `DELETE /api/v1/categories/:id`: カテゴリの更新と削除。

### 2.2. モデル

- **`Actual.rb`**:
    - `belongs_to :user`
    - `belongs_to :category`
    - `validates :start_time, :end_time, presence: true`
    - `validate :end_time_after_start_time` (終了時刻が開始時刻より後か検証)
- **`Category.rb`**:
    - `belongs_to :user`
    - `has_many :actuals`
    - `validates :name, presence: true`
- **`User.rb`**:
    - `has_many :actuals, dependent: :destroy`
    - `has_many :categories, dependent: :destroy`

### 2.3. バリデーション

- 各コントローラで、`strong_parameters` を使用して、許可されたパラメータのみを受け付ける。
- モデルレベルでのバリデーションを徹底し、データの整合性を保つ。

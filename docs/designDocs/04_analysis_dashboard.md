# 設計書: 04 分析ダッシュボード機能

## 1. フロントエンド設計 (Vue.js)

### 1.1. 関連コンポーネント

- **`views/DashboardView.vue`**: ダッシュボードページ全体。期間選択UIと各グラフコンポーネントを配置。
- **`components/specific/dashboard/PeriodSelector.vue`**: 「日次/週次/月次」と対象期間を選択するUI。
    - 選択が変更されたら `dashboardStore.fetchDashboardData()` を呼び出す。
- **`components/specific/dashboard/CategoryPieChart.vue`**: カテゴリ別円グラフを描画 (`vue-chartjs` を利用)。
- **`components/specific/dashboard/ActivityBarChart.vue`**: 日別活動時間の積み上げ棒グラフを描画。
- **`components/specific/dashboard/ProductivityLineChart.vue`**: 生産性指標の折れ線グラフを描画。
- **`components/specific/dashboard/PlanActualBarChart.vue`**: 予定vs実績の比較棒グラフを描画。

### 1.2. 状態管理 (Pinia: `stores/dashboard.js`)

- **State**:
    - `period: 'daily' | 'weekly' | 'monthly'`: 選択中の期間種別。
    - `targetDate: Date`: 対象の日付。
    - `dashboardData: object | null`: バックエンドから取得したグラフ用のデータ。
    - `isLoading: boolean`: ローディング状態。
- **Actions**:
    - `setPeriod(period)`: 期間種別を変更。
    - `setTargetDate(date)`: 対象日付を変更。
    - `fetchDashboardData()`: 現在の `period` と `targetDate` を元に、バックエンドからデータを取得し `dashboardData` を更新する。

### 1.3. グラフ描画

- `vue-chartjs` (Chart.jsのVueラッパー) を利用する。
- 各グラフコンポーネントは、`dashboardStore` から必要なデータを `props` として受け取り、Chart.jsが要求する形式に変換してチャートを描画する。

## 2. バックエンド設計 (Ruby on Rails)

### 2.1. APIエンドポイント

- **`GET /api/v1/dashboard`**
    - **コントローラ**: `Api::V1::DashboardController#show`
    - **パラメータ**: `params[:period]`, `params[:date]`
    - **処理フロー**:
        1. パラメータに基づいて期間 (`time_range`) を計算。
        2. `DashboardDataQuery` のようなクエリオブジェクト/サービスクラスを使い、必要なデータを集計する。
        3. 各グラフに必要なデータをハッシュとしてまとめてJSONで返す。

### 2.2. データ集計 (クエリオブジェクト)

- `DashboardDataQuery` のようなクラスを作成し、コントローラからビジネスロジックを分離する。
- **`initialize(user, time_range)`**: ユーザーと期間を受け取る。
- **`category_distribution`**: カテゴリ別の合計時間を計算。
    - `current_user.actuals.within(time_range).group('categories.name').sum('duration')` のようなクエリを発行。（`duration`は`actuals`モデルで`end_time - start_time`として計算するメソッドを定義しておくと便利）
- **`daily_activity`**: 日別のカテゴリ積み上げデータを計算。
    - `group_by_day(:start_time).group('categories.name').sum('duration')` のように日別・カテゴリ別に集計。
- **`productivity_trend`**: 生産性指標のトレンドを計算。
    - 生産/非生産カテゴリを `where`句で指定し、日別に集計。

### 2.3. パフォーマンス

- `actuals` テーブルの `user_id`, `start_time`, `category_id` に複合インデックスを貼ることを検討する。
- 大量のデータを集計するため、クエリは極力ActiveRecordで完結させ、Rubyレベルでのループ処理を避ける。
- 必要であれば、集計結果をキャッシュすることも検討する。

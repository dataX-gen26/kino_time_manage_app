# フロントエンド設計書

## 1. 概要

本ドキュメントは、「予実管理AIアシスタントアプリ」のフロントエンドアーキテクチャとコンポーネント設計について定義する。

## 2. アーキテクチャ & 使用ライブラリ

- **フレームワーク**: Vue.js 3 (Composition APIベース)
- **テンプレートエンジン**: `Pug`
- **CSSプリプロセッサ**: `Sass (SCSS記法)`
- **UIライブラリ**: `bootstrap-vue-next`
- **ルーティング**: `vue-router` (必須)
- **HTTPクライアント**: Axios
- **日付操作**: `date-fns`
- **グラフ描画**: `vue-chartjs`
- **Markdownパーサー**: `marked`
- **ビルドツール**: Vite

## 3. ディレクトリ構成

```
# Railsプロジェクトルート
my_rails_app/
├── app/
│   ├── javascript/      # Vue.jsのソースコード
│   │   ├── api/           # API通信層 (Axiosインスタンス、各リソースのAPIクライアント)
│   │   ├── assets/        # 静的ファイル (CSS, 画像)
│   │   ├── components/    # 再利用可能なUIコンポーネント
│   │   ├── composables/   # 再利用可能なロジック (Composition API)
│   │   ├── router/        # Vue Routerの設定
│   │   ├── stores/        # Piniaストア (状態管理)
│   │   ├── utils/         # ユーティリティ関数 (日付フォーマットなど)
│   │   ├── views/         # 各ページに対応するビューコンポーネント
│   │   ├── entrypoints/   # エントリーポイント (Vueインスタンスをマウント)
│   │   │   └── application.js
│   │   ├── App.vue        # ルートコンポーネント
│   │   └── vite.svg       # Viteのデフォルトファイルなど
│   └── views/
│       └── layouts/
│           └── application.html.erb  # ここでViteのタグヘルパーを読み込む
├── public/
├── vite.config.ts         # Viteの設定ファイル (Railsプロジェクトルート)
└── package.json
```

## 4. ビルドとデプロイ

- **ビルド**: Railsのデプロイプロセス（例: `rails assets:precompile`）の一部として、Vite RubyなどのGemがVue.jsアプリケーションを自動的にビルドし、Railsのアセットパイプラインを通じて配信可能な形式に変換する。
- **デプロイ**: Railsアプリケーションのデプロイと同時に、Vue.jsのビルド成果物もデプロイされる。

## 5. 開発環境

- **フロントエンド開発サーバー**: `bin/vite dev` コマンド（Vite Rubyの場合）で起動する。Railsサーバーとは独立して動作し、ホットリロードを提供する。
- **APIリクエスト**: フロントエンドからのAPIリクエストは、Railsサーバー（例: `http://localhost:3000`）に直接送信される。Vite開発サーバーは、Railsサーバーへのプロキシとして機能するよう設定される（`vite.config.ts`）。

## 6. 状態管理 (Pinia)

機能ごとにストアを分割して管理する。

- **`auth.js`**: ユーザーの認証情報、ログイン状態を管理。
- **`calendar.js`**: 表示中の日付、Googleカレンダーの予定データ、実績データを管理。
- **`ui.js`**: モーダルの表示状態、ローディング状態など、UIに関する状態を管理。
- **`categories.js`**: ユーザーが作成したカテゴリの一覧を管理。
- **`weeklyGoals.js`**: 週次目標、およびその進捗データを管理。

## 7. コンポーネント設計（概要）

詳細は各機能の設計書で記述するが、主要なコンポーネントは以下の通り。

- **`App.vue`**: ルータービューを配置し、全体のレイアウトを決定する。
- **`HomeView.vue`**: ログイン前のトップページ。
- **`MainView.vue`**: ログイン後のメイン画面。カレンダーUI全体を統括する。
    - **`TheHeader.vue`**: ヘッダーコンポーネント。
    - **`DateNavigator.vue`**: 日付ナビゲーションコンポーネント。
    - **`CalendarGrid.vue`**: 時間軸、予定、実績のグリッド表示を担当。
        - **`PlanColumn.vue`**: 予定列。
        - **`ActualColumn.vue`**: 実績列。
    - **`ActualFormModal.vue`**: 実績の登録・編集用モーダル。週次目標進捗記入欄を内包する。
- **`WeeklyGoalSettingModal.vue`**: 週次目標の設定・編集用モーダル。
- **`WeeklyReviewView.vue`**: 週次目標の振り返り画面。
- **`DashboardView.vue`**: 分析ダッシュボードページ。
    - **`CategoryPieChart.vue`**: カテゴリ別円グラフ。
    - **`ActivityBarChart.vue`**: 日別活動時間積み上げ棒グラフ。

## 8. ルーティング (Vue Router)

- `/`: `HomeView` (未認証時) / `MainView` (認証時) - `beforeEnter`ガードで振り分け
- `/dashboard`: `DashboardView` (認証が必要)
- `/weekly-goals`: `WeeklyReviewView` (週次目標の振り返り画面、認証が必要)
- `/login`: ログイン処理中の中間ページ（必要であれば）

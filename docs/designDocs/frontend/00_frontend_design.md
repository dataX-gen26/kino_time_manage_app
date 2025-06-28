# フロントエンド設計書

## 1. 概要

本ドキュメントは、「予実管理AIアシスタントアプリ」のフロントエンドアーキテクチャとコンポーネント設計について定義する。

## 2. アーキテクチャ & 使用ライブラリ

- **フレームワーク**: Vue.js 3 (Composition APIベース)
- **テンプレートエンジン**: `Pug`
- **CSSプリプロセッサ**: `Sass (SCSS記法)`
- **UIライブラリ**: `bootstrap-vue-next`
- **状態管理**: Pinia
- **ルーティング**: `vue-router` (必須)
- **HTTPクライアント**: Axios
- **日付操作**: `date-fns`
- **グラフ描画**: `vue-chartjs`
- **Markdownパーサー**: `marked`
- **ビルドツール**: Vite

## 3. ディレクトリ構成

```
src/
├── api/               # API通信層 (Axiosインスタンス、各リソースのAPIクライアント)
├── assets/            # 静的ファイル (CSS, 画像)
├── components/        # 再利用可能なUIコンポーネント
│   ├── common/        # アプリケーション全体で使われる汎用コンポーネント (ボタン, モーダルなど)
│   ├── layout/        # ヘッダー, フッター, サイドバーなどのレイアウトコンポーネント
│   └── specific/      # 特定の機能に特化したコンポーネント (カレンダーグリッド, 分析グラフなど)
├── composables/       # 再利用可能なロジック (Composition API)
├── router/            # Vue Routerの設定
├── stores/            # Piniaストア (状態管理)
├── utils/             # ユーティリティ関数 (日付フォーマットなど)
├── views/             # 各ページに対応するビューコンポーネント
├── App.vue            # ルートコンポーネント
└── main.js            # アプリケーションのエントリポイント
```

## 4. 状態管理 (Pinia)

機能ごとにストアを分割して管理する。

- **`auth.js`**: ユーザーの認証情報（JWTトークン）、ログイン状態を管理。
- **`calendar.js`**: 表示中の日付、Googleカレンダーの予定データ、実績データを管理。
- **`ui.js`**: モーダルの表示状態、ローディング状態など、UIに関する状態を管理。
- **`categories.js`**: ユーザーが作成したカテゴリの一覧を管理。

## 5. コンポーネント設計（概要）

詳細は各機能の設計書で記述するが、主要なコンポーネントは以下の通り。

- **`App.vue`**: ルータービューを配置し、全体のレイアウトを決定する。
- **`HomeView.vue`**: ログイン前のトップページ。
- **`MainView.vue`**: ログイン後のメイン画面。カレンダーUI全体を統括する。
    - **`TheHeader.vue`**: ヘッダーコンポーネント。
    - **`DateNavigator.vue`**: 日付ナビゲーションコンポーネント。
    - **`CalendarGrid.vue`**: 時間軸、予定、実績のグリッド表示を担当。
        - **`PlanColumn.vue`**: 予定列。
        - **`ActualColumn.vue`**: 実績列。
    - **`ActualFormModal.vue`**: 実績の登録・編集用モーダル。
- **`DashboardView.vue`**: 分析ダッシュボードページ。
    - **`CategoryPieChart.vue`**: カテゴリ別円グラフ。
    - **`ActivityBarChart.vue`**: 日別活動時間積み上げ棒グラフ。

## 6. ルーティング (Vue Router)

- `/`: `HomeView` (未認証時) / `MainView` (認証時) - `beforeEnter`ガードで振り分け
- `/dashboard`: `DashboardView` (認証が必要)
- `/login`: ログイン処理中の中間ページ（必要であれば）

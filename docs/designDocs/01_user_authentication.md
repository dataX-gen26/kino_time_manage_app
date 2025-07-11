# 設計書: 01 ユーザー認証機能 (PKCE付き認可コードフロー)

## 1. フロントエンド設計 (Vue.js)

### 1.1. 概要

PKCE (Proof Key for Code Exchange) 付き認可コードフローに基づき、フロントエンドが認証プロセスを開始し、受け取った認可コードをバックエンドに渡してセッションを作成する。

### 1.2. 関連コンポーネント

- **`views/HomeView.vue`**: 未ログイン時のトップページ。「Googleでログイン」ボタンを表示。
- **`views/AuthCallback.vue`**: Googleからのリダイレクトを受け取るための専用ビュー。認可コードを抽出し、バックエンドに送信する役割を担う。

### 1.3. 状態管理 (Pinia: `stores/auth.js`)

- **State**:
    - `user: object | null`: ログイン中のユーザー情報。
    - `isLoggedIn: boolean`: ログイン状態の算出プロパティ。
- **Actions**:
    - `redirectToGoogle()`: PKCEの `code_verifier` と `code_challenge` を生成。`code_verifier` はセッションストレージに保存し、`code_challenge` を付けてGoogleの認証URLにリダイレクトする。
    - `handleAuthCallback(code: string)`: `AuthCallback.vue` から呼び出される。セッションストレージから `code_verifier` を取り出し、引数の `code` と共にバックエンドAPI (`/api/v1/auth/google/callback`) に送信する。成功したらユーザー情報をステートに保存し、メインページに遷移する。
    - `logout()`: バックエンドのログアウトAPIを呼び出し、ステートをクリアする。

### 1.4. シーケンス

1.  ユーザーが `HomeView` でログインボタンをクリックし `authStore.redirectToGoogle()` を実行。
2.  フロントエンドは `code_verifier` を生成・保存し、`code_challenge` と共にGoogleへリダイレクト。
3.  認証後、Googleは `/auth/callback?code=...` にリダイレクト。
4.  `AuthCallback.vue` がマウントされ、`authStore.handleAuthCallback(code)` を実行。
5.  `handleAuthCallback` がバックエンドに `code` と `code_verifier` を送信。
6.  バックエンドからユーザー情報が返され、ログイン状態が確立される。

## 2. バックエンド設計 (Ruby on Rails)

### 2.1. 認証ロジック

フロントエンドから渡された認可コードと `code_verifier` を使用してGoogleと通信し、アクセストークンを取得してユーザーを認証する。

### 2.2. APIエンドポイント

- **`POST /api/v1/auth/google/callback`**:
    - `params` から `code` と `code_verifier` を受け取る。
    - 受け取った情報と、サーバーで管理している `client_id`, `client_secret` を使ってGoogleのトークンエンドポイントにリクエストを送信する。
    - Googleから受け取ったアクセストークンでユーザー情報を取得。
    - ユーザーをDBで検索または新規作成し、`log_in(user)` でセッションを作成する。
    - 成功したらユーザー情報をJSONで返す。
- **`DELETE /api/v1/auth/logout`**: 
    - `log_out` メソッドでセッションを破棄する。
- **`GET /api/v1/sessions/check`**: 
    - `current_user` が存在すれば、そのユーザー情報をJSONで返す。

### 2.3. ヘルパー/コントローラメソッド

- `log_in(user)`: セッションに `user_id` を保存する。
- `log_out`: セッションと `current_user` をクリアする。
- `current_user`: セッションから現在のログインユーザーを取得する。
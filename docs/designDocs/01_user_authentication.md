# 設計書: 01 ユーザー認証機能 (記憶トークン方式)

## 1. フロントエンド設計 (Vue.js)

### 1.1. 概要

認証管理の責務は主にバックエンドが負う。フロントエンドは、APIリクエスト時にブラウザが自動で送信するクッキーを利用し、認証状態をバックエンドに問い合わせることでUIを制御する。

### 1.2. 関連コンポーネント

- **`views/HomeView.vue`**: 未ログイン時のトップページ。「Googleでログイン」ボタンと、「ログイン状態を維持する」チェックボックスを表示。
- **`components/layout/TheHeader.vue`**: ログイン状態に応じてUIを切り替える。

### 1.3. 状態管理 (Pinia: `stores/auth.js`)

- **State**:
    - `user: object | null`: ログイン中のユーザー情報。
    - `isLoggedIn: boolean`: ログイン状態の算出プロパティ (`user`の有無で判定)。
    - `isLoading: boolean`: 認証状態の確認中を示すフラグ。
- **Actions**:
    - `checkAuth()`: アプリケーション起動時に呼び出す。バックエンドに現在のセッション状態を問い合わせ、ログインしていればユーザー情報を取得する。
    - `loginWithGoogle(persist: boolean)`: ログイン処理を開始する。実際のリダイレクト先URLに `persist` パラメータを含める。
    - `logout()`: バックエンドのログアウトAPIを呼び出し、成功したら `user` ステートをクリアする。

### 1.4. シーケンス

- **ログイン**: 
    1. ユーザーが `HomeView` でチェックボックスを選択し、ログインボタンをクリック。
    2. `window.location.href = '/api/v1/auth/google_oauth2?persist=true'` のようにして、バックエンドの認証エンドポイントに直接遷移させる。
    3. 認証成功後、バックエンドからフロントエンドのメインページにリダイレクトされる。
- **アプリケーション初期化**: 
    1. アプリ起動時に `authStore.checkAuth()` を呼び出す。
    2. `GET /api/v1/sessions/check` をリクエスト。(クッキーはブラウザが自動で送信)
    3. バックエンドからユーザー情報が返ってくれば、`user` ステートを更新してログイン状態にする。401エラーなら未ログイン状態のままにする。

## 2. バックエンド設計 (Ruby on Rails)

### 2.1. 認証ロジック

- `ApplicationController` に、セッションと記憶トークンによるユーザー認証のロジックを実装する。

### 2.2. APIエンドポイント

- **`GET /api/v1/auth/google_oauth2`**: 
    - `params[:persist]` の値をセッションに一時保存 (`session[:persist_login] = true`) してから、OmniAuthのフローを開始する。
- **`GET /api/v1/auth/google_oauth2/callback`**: 
    - ユーザー認証・登録処理を行う。
    - `session[:persist_login]` がtrueなら、`remember(user)` メソッドを呼び出す。
    - 最後にフロントエンドのURL (`/`) にリダイレクトする。
- **`DELETE /api/v1/auth/logout`**: 
    - `forget(current_user)` メソッドで永続クッキーを削除し、`log_out` メソッドでセッションを破棄する。
- **`GET /api/v1/sessions/check`**: 
    - `current_user` が存在すれば、そのユーザー情報をJSONで返す。
    - 存在しなければ `401 Unauthorized` を返す。

### 2.3. モデル (`User.rb`)

- `attr_accessor :remember_token` を追加し、ハッシュ化する前のトークンを一時的に保持できるようにする。
- `User.new_token`: URLセーフなランダムトークンを生成するクラスメソッド。
- `remember`: `remember_token` を生成し、そのダイジェストを `remember_digest` としてDBに保存するインスタンスメソッド。
- `authenticated?(remember_token)`: 渡されたトークンがDBのダイジェストと一致するか検証するメソッド。
- `forget`: `remember_digest` を `nil` に更新するメソッド。

### 2.4. ヘルパー/コントローラメソッド

- `remember(user)`: ユーザーを記憶する（トークン生成、DB保存、クッキー設定）。
- `forget(user)`: ユーザーの永続セッションを破棄する。
- `log_in(user)`: セッションに `user_id` を保存する。
- `log_out`: セッションと `current_user` をクリアする。
- `current_user`: セッションまたは永続クッキーから現在のログインユーザーを取得する。
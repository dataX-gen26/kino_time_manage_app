# 外部サービス連携と環境設定の手順

本ドキュメントは、アプリケーション開発に必要な外部サービスのAPIキー設定や、ローカルでの認証情報管理についての手順をまとめたものである。

## 1. Google Cloud Platform: OAuth 2.0 クライアントIDの発行

Googleカレンダー連携とGoogleログイン機能に必要となる認証情報を取得する。

### 1.1. プロジェクトの作成とAPIの有効化

1.  **Google Cloud Consoleにアクセス**: [https://console.cloud.google.com/](https://console.cloud.google.com/)
2.  **プロジェクトの選択/作成**: 
    - 画面上部のプロジェクト選択プルダウンから「新しいプロジェクト」をクリック。
    - プロジェクト名（例: `Kino-Time-Management-App`）を入力して「作成」。
3.  **APIとサービスの有効化**: 
    - 作成したプロジェクトを選択した状態で、左側のナビゲーションメニューから「APIとサービス」>「ライブラリ」を選択。
    - 検索窓で「**Google Calendar API**」を検索し、選択して「有効にする」ボタンをクリック。
    - 同様に、「**Google People API**」を検索し、有効にする。（OmniAuthでのプロフィール情報取得に利用される場合がある）

### 1.2. OAuth同意画面の設定

1.  左側メニューから「APIとサービス」>「OAuth同意画面」を選択。
2.  **User Type**: 「**外部**」を選択して「作成」。
3.  **アプリ情報**: 
    - アプリ名: `Kino Time Management App`
    - ユーザーサポートメール: 自分のメールアドレスを選択
    - デベロッパーの連絡先情報: 自分のメールアドレスを入力
    - 「保存して次へ」をクリック。
4.  **スコープ**: 
    - 「スコープを追加または削除」ボタンをクリック。
    - 右側に表示されるフィルタで「Google Calendar API」を選択。
    - `.../auth/calendar.readonly` をチェック。
    - `.../auth/userinfo.email` と `.../auth/userinfo.profile` がデフォルトで含まれていることを確認。
    - 「更新」ボタンをクリックし、「保存して次へ」をクリック。
5.  **テストユーザー**: 
    - 「ユーザーを追加」ボタンをクリックし、ログインに使用する自分のGoogleアカウントのメールアドレスを入力して「追加」。
    - 「保存して次へ」をクリック。
6.  内容を確認し、「ダッシュボードに戻る」をクリック。

### 1.3. 認証情報（クライアントIDとシークレット）の作成

1.  左側メニューから「APIとサービス」>「認証情報」を選択。
2.  画面上部の「+ 認証情報を作成」をクリックし、「**OAuthクライアントID**」を選択。
3.  **アプリケーションの種類**: 「**ウェブアプリケーション**」を選択。
4.  **名前**: `Kino Time Management App - Web Client` など分かりやすい名前を入力。
5.  **承認済みのリダイレクトURI**: 
    - 「+ URIを追加」ボタンをクリック。
    - ローカル開発環境用に `http://localhost:3000/api/v1/auth/google_oauth2/callback` を入力。
    - `3000` はRailsサーバーのポート番号。環境に合わせて変更すること。
6.  「作成」ボタンをクリック。
7.  表示された「**クライアントID**」と「**クライアントシークレット**」をコピーして、安全な場所に控えておく。**この情報は絶対にGitなどにコミットしないこと。**

## 2. Google AI Studio: Gemini APIキーの取得

AIによるフィードバック機能で必要となる。

1.  **Google AI Studioにアクセス**: [https://aistudio.google.com/](https://aistudio.google.com/)
2.  Googleアカウントでログイン。
3.  左側のメニューから「**Get API key**」を選択。
4.  「**Create API key in new project**」ボタンをクリック。
5.  表示されたAPIキーをコピーして、安全な場所に控えておく。

## 3. Rails: 認証情報の安全な管理 (`credentials`)

上記で取得したクライアントID、シークレット、APIキーをRailsアプリケーションで安全に管理する。

1.  **credentialsファイルの編集**: 
    - ターミナルでRailsプロジェクトのルートディレクトリに移動。
    - 以下のコマンドを実行する。`EDITOR`には好みのエディタを指定（例: `EDITOR="code --wait"`）。
    ```bash
    EDITOR="vim" bin/rails credentials:edit
    ```
2.  **認証情報の追加**: 
    - 開かれた `credentials.yml.enc` の編集画面に、以下のように情報を記述する。
    ```yaml
    google_oauth2:
      client_id: "ここにコピーしたクライアントIDを貼り付け"
      client_secret: "ここにコピーしたクライアントシークレットを貼り付け"

    gemini:
      api_key: "ここにコピーしたGemini APIキーを貼り付け"
    ```
3.  **保存して終了**: 
    - ファイルを保存してエディタを閉じると、`config/credentials.yml.enc`（暗号化されたファイル）と `config/master.key`（復号キー）が更新される。
    - `master.key`は`.gitignore`に含まれており、絶対にGitで管理しないこと。

4.  **コードからの参照**: 
    - コード内からは `Rails.application.credentials.google_oauth2[:client_id]` のようにして安全に値を取得できる。

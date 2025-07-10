# ライブラリ・技術スタック実装メモ

## 1. フロントエンド (Vue.js)

### 1.1. Google API + PKCEフロー

PKCE (Proof Key for Code Exchange) は、クライアントの正当性を証明するための仕組みです。

**実装手順:**

1.  **`code_verifier` の生成**: ログイン試行ごとに、ランダムで十分に長い文字列を生成します。これを `code_verifier` とします。
    - 例: `crypto.randomUUID()` や同様のメソッドで生成。
    - この値を、後のトークン交換で使うために **セッションストレージ** に保存します。

2.  **`code_challenge` の生成**: `code_verifier` を **SHA-256** でハッシュ化し、その結果を **Base64URL** 形式でエンコードします。これが `code_challenge` となります。
    - JavaScriptでの実装例:
      ```javascript
      async function generateCodeChallenge(verifier) {
        const encoder = new TextEncoder();
        const data = encoder.encode(verifier);
        const digest = await window.crypto.subtle.digest('SHA-256', data);
        return window.btoa(String.fromCharCode(...new Uint8Array(digest)))
          .replace(/\+/g, '-')
          .replace(/\//g, '_')
          .replace(/=/g, '');
      }
      ```

3.  **Google認証URLへのリダイレクト**: 以下のパラメータを含んだURLを生成し、ユーザーをリダイレクトさせます。
    - `client_id`: Google Cloud Consoleで取得したクライアントID。
    - `redirect_uri`: Googleからのコールバックを受け取るフロントエンドのURL (例: `http://localhost:5173/auth/callback`)。
    - `response_type`: `code` を指定。
    - `scope`: 要求する権限 (例: `openid profile email`)。
    - `code_challenge`: ステップ2で生成した値。
    - `code_challenge_method`: `S256` を指定。

### 1.2. AxiosによるAPI連携

- **`withCredentials: true`**: 異なるドメイン間でCookie（RailsのセッションIDなど）を送受信するために必須の設定です。これを有効にしないと、バックエンドでセッションを維持できません。

- **CSRF対策**: 
    - `ApplicationController` で `protect_from_forgery` が有効になっている場合、Railsは `GET`以外のリクエストに対してCSRFトークンを要求します。
    - **実装フロー**:
        1. Vueアプリの起動時（例: `main.js`）に、まずバックエンドの `/api/v1/csrf_token` エンドポイントにリクエストを送り、トークンを取得します。
        2. 取得したトークンを、`axios` のカスタムインスタンスのデフォルトヘッダーに設定します。
           ```javascript
           // api/client.js
           import axios from 'axios';

           const apiClient = axios.create({
             baseURL: import.meta.env.VITE_API_BASE_URL,
             withCredentials: true,
           });

           // main.js or a boot file
           import apiClient from './api/client';

           async function initializeApp() {
             try {
               const response = await apiClient.get('/csrf_token');
               apiClient.defaults.headers.common['X-CSRF-Token'] = response.data.csrf_token;
             } catch (error) {
               console.error('CSRF token fetch failed:', error);
             }
             // ...Vue app mount...
           }

           initializeApp();
           ```

## 2. バックエンド (Ruby on Rails)

### 2.1. Google API連携 (PKCE)

- フロントエンドから `code` と `code_verifier` を受け取った後、バックエンドはGoogleのトークンエンドポイント (`https://oauth2.googleapis.com/token`) にPOSTリクエストを送信します。
- このリクエストには、以下のパラメータを含める必要があります。
    - `client_id`: Railsのcredentialsで管理。
    - `client_secret`: Railsのcredentialsで管理。
    - `code`: フロントエンドから受け取った認可コード。
    - `code_verifier`: フロントエンドから受け取った`code_verifier`。
    - `grant_type`: `authorization_code` を指定。
    - `redirect_uri`: フロントエンドで指定したものと同じリダイレクトURI。
- `httparty` や `faraday` などのHTTPクライアントGemを使用すると、このリクエストを簡単に実装できます。

### 2.2. CORS (`rack-cors`)

- `config/initializers/cors.rb` で設定します。
- **重要な設定項目**:
    - `origins`: 許可するフロントエンドのオリジンを指定します。環境変数で管理するのが望ましいです。
    - `methods`: 許可するHTTPメソッド (`:get, :post, :put, :patch, :delete, :options, :head`)。
    - `credentials: true`: `axios` の `withCredentials` に対応し、Cookieの送受信を許可するために必須です。

    ```ruby
    # config/initializers/cors.rb
    Rails.application.config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins ENV.fetch('CORS_ALLOWED_ORIGINS', 'http://localhost:5173') # 環境変数で管理

        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          credentials: true
      end
    end
    ```

### 2.3. CSRFトークンの提供

- `ApplicationController` で `protect_from_forgery` を有効にしつつ、CSRFトークンを返すためのコントローラを作成します。

    ```ruby
    # app/controllers/api/v1/csrf_tokens_controller.rb
    class Api::V1::CsrfTokensController < ApplicationController
      def show
        render json: { csrf_token: form_authenticity_token }
      end
    end

    # config/routes.rb
    namespace :api do
      namespace :v1 do
        resource :csrf_token, only: [:show]
        # ... other routes
      end
    end
    ```
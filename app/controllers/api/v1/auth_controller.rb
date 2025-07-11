class Api::V1::AuthController < ApplicationController
  skip_before_action :verify_authenticity_token
  def google_callback
    code = params.require(:auth).permit(:code)[:code]
    code_verifier = params.require(:auth).permit(:code_verifier)[:code_verifier]

    response = HTTParty.post('https://oauth2.googleapis.com/token', body: {
      client_id: Rails.application.credentials.google_oauth2[:client_id],
      client_secret: Rails.application.credentials.google_oauth2[:client_secret],
      code: code,
      code_verifier: code_verifier,
      grant_type: 'authorization_code',
      redirect_uri: "http://localhost:5173/auth/callback"
    })

    if response.success?
      id_token = response['id_token']
      user_info = HTTParty.get("https://oauth2.googleapis.com/tokeninfo?id_token=#{id_token}")

      if user_info.success?
        user = User.find_or_create_by(google_id: user_info['sub']) do |u|
          u.email = user_info['email']
          u.name = user_info['name']
          u.avatar_url = user_info['picture']
          u.access_token = response['access_token']
          u.refresh_token = response['refresh_token']
        end

        session[:user_id] = user.id
        render json: user
      else
        render json: { error: 'Invalid ID token' }, status: :unauthorized
      end
    else
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end

  def logout
    session[:user_id] = nil
    head :no_content
  end
end
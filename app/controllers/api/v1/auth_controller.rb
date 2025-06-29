class Api::V1::AuthController < ApplicationController
  def google_oauth2
    session[:persist_login] = params[:persist] == 'true'
    redirect_to '/auth/google_oauth2'
  end

  def google_oauth2_callback
    auth = request.env['omniauth.auth']
    user = User.find_or_create_by(provider: auth['provider'], uid: auth['uid']) do |u|
      u.email = auth['info']['email']
      u.name = auth['info']['name']
      u.image = auth['info']['image']
    end

    if user.persisted?
      log_in user
      remember(user) if session[:persist_login]
      session.delete(:persist_login)
      redirect_to ENV['FRONTEND_URL'] || '/'
    else
      redirect_to ENV['FRONTEND_URL'] || '/', alert: 'Google認証に失敗しました。'
    end
  end

  def logout
    log_out
    head :no_content
  end
end

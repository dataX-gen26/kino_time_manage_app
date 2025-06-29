class Api::V1::SessionsController < ApplicationController
  def check
    if logged_in?
      render json: current_user
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end

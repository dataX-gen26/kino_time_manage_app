class Api::V1::UsersController < ApplicationController
  def me
    if current_user
      render json: current_user
    else
      render json: { user: nil }
    end
  end
end

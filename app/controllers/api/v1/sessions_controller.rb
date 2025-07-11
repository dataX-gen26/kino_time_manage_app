class Api::V1::SessionsController < ApplicationController
  def check
    if current_user
      render json: current_user
    else
      render json: { user: nil }, status: :ok
    end
  end
end
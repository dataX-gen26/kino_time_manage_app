class Api::V1::AiController < ApplicationController
  before_action :authenticate_user!

  def daily_review
    date = params[:date] ? Date.parse(params[:date]) : Date.current
    service = AiFeedbackService.new(current_user, date)
    feedback = service.generate_daily_review
    render json: { feedback: feedback }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
end

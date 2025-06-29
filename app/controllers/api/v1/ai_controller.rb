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

  def weekly_review
    weekly_goal = current_user.weekly_goals.find(params[:weekly_goal_id])
    service = AiFeedbackService.new(current_user, nil) # Date is not directly used for weekly review
    feedback = service.generate_weekly_review(weekly_goal)
    render json: { feedback: feedback }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
end

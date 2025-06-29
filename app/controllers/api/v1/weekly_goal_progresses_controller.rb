class Api::V1::WeeklyGoalProgressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_weekly_goal

  def index
    @weekly_goal_progresses = @weekly_goal.weekly_goal_progresses
    render json: @weekly_goal_progresses
  end

  def create
    @weekly_goal_progress = @weekly_goal.weekly_goal_progresses.build(weekly_goal_progress_params)
    if @weekly_goal_progress.save
      render json: @weekly_goal_progress, status: :created
    else
      render json: @weekly_goal_progress.errors, status: :unprocessable_entity
    end
  end

  private

  def set_weekly_goal
    @weekly_goal = current_user.weekly_goals.find(params[:weekly_goal_id])
  end

  def weekly_goal_progress_params
    params.require(:weekly_goal_progress).permit(:actual_id, :progress_date, :content)
  end
end

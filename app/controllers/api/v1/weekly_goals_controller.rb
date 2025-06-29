class Api::V1::WeeklyGoalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_weekly_goal, only: [:show, :update, :destroy]

  def index
    @weekly_goals = current_user.weekly_goals
    render json: @weekly_goals
  end

  def show
    render json: @weekly_goal
  end

  def create
    @weekly_goal = current_user.weekly_goals.build(weekly_goal_params)
    if @weekly_goal.save
      render json: @weekly_goal, status: :created
    else
      render json: @weekly_goal.errors, status: :unprocessable_entity
    end
  end

  def update
    if @weekly_goal.update(weekly_goal_params)
      render json: @weekly_goal
    else
      render json: @weekly_goal.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @weekly_goal.destroy
    head :no_content
  end

  private

  def set_weekly_goal
    @weekly_goal = current_user.weekly_goals.find(params[:id])
  end

  def weekly_goal_params
    params.require(:weekly_goal).permit(:start_date, :end_date, :title, :description, :status)
  end
end

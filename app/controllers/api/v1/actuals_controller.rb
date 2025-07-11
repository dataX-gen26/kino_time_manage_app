class Api::V1::ActualsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_actual, only: [:update, :destroy]

  def index
    date = params[:date] ? Date.parse(params[:date]) : Date.current
    @actuals = current_user.actuals.where(start_time: date.all_day).order(:start_time)
    render json: @actuals
  end

  def create
    @actual = current_user.actuals.build(actual_params)
    if @actual.save
      render json: @actual, status: :created
    else
      render json: @actual.errors, status: :unprocessable_entity
    end
  end

  def update
    if @actual.update(actual_params)
      render json: @actual
    else
      render json: @actual.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @actual.destroy
    head :no_content
  end

  private

  def set_actual
    @actual = current_user.actuals.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Actual not found" }, status: :not_found
  end

  def actual_params
    params.require(:actual).permit(:title, :start_time, :end_time, :category_id)
  end

  def authenticate_user!
    unless current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
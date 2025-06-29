class Api::V1::ActualsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_actual, only: [:show, :update, :destroy]

  def index
    @actuals = current_user.actuals.where(start_time: params[:date].to_date.all_day)
    render json: @actuals
  end

  def show
    render json: @actual
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
  end

  def actual_params
    params.require(:actual).permit(:category_id, :start_time, :end_time, :content, :is_problem)
  end
end

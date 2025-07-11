class Api::V1::CalendarController < ApplicationController
  before_action :authenticate_user!

  def events
    date = params[:date] ? Date.parse(params[:date]) : Date.current
    time_min = date.beginning_of_day.utc
    time_max = date.end_of_day.utc

    begin
      events = GoogleCalendarService.new(current_user).fetch_events(time_min, time_max)
      render json: events
    rescue Google::Apis::ClientError => e
      Rails.logger.error("Google Calendar API error: #{e.message}")
      render json: { error: "Failed to fetch calendar events: #{e.message}" }, status: :internal_server_error
    rescue Google::Auth::TokenRefreshError => e
      Rails.logger.error("Google token refresh error: #{e.message}")
      render json: { error: "Google token expired or invalid. Please re-authenticate." }, status: :unauthorized
    rescue StandardError => e
      Rails.logger.error("Unexpected error fetching calendar events: #{e.message}")
      render json: { error: "An unexpected error occurred." }, status: :internal_server_error
    end
  end

  private

  def authenticate_user!
    # ここでは仮の認証ロジック。実際にはdevise_token_authなどを使用
    # current_user が存在しない場合はエラーを返す
    unless current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
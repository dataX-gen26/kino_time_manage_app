class Api::V1::CalendarController < ApplicationController
  before_action :authenticate_user!

  def events
    date = Date.parse(params[:date])
    service = GoogleCalendarService.new(current_user)
    events = service.fetch_events(date)
    render json: events.items.map { |event| format_event(event) }
  rescue Google::Apis::AuthorizationError
    render json: { error: "Authorization required" }, status: :unauthorized
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def authenticate_user!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
  end

  def format_event(event)
    {
      id: event.id,
      summary: event.summary,
      start: event.start.date_time || event.start.date,
      end: event.end.date_time || event.end.date,
      htmlLink: event.html_link,
    }
  end
end

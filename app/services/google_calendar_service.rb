class GoogleCalendarService
  require "google/apis/calendar_v3"
  require "googleauth"
  require "googleauth/stores/file_token_store"

  attr_reader :user

  def initialize(user)
    @user = user
    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.client_options.application_name = "Kino Time Manage App"
    @service.authorization = authorize
  end

  def fetch_events(date)
    start_of_day = date.beginning_of_day.iso8601
    end_of_day = date.end_of_day.iso8601

    @service.list_events(
      'primary',
      time_min: start_of_day,
      time_max: end_of_day,
      single_events: true,
      order_by: 'startTime',
    )
  rescue Google::Apis::AuthorizationError => e
    Rails.logger.error "Google Calendar API Authorization Error: #{e.message}"
    # TODO: Implement token refresh logic here
    raise e
  rescue Google::Apis::ClientError => e
    Rails.logger.error "Google Calendar API Client Error: #{e.message}"
    raise e
  end

  private

  def authorize
    credentials = Google::Auth::UserRefreshCredentials.new(
      client_id: ENV["GOOGLE_CLIENT_ID"],
      client_secret: ENV["GOOGLE_CLIENT_SECRET"],
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY,
      access_token: user.access_token,
      refresh_token: user.refresh_token,
      expires_at: user.expires_at,
    )

    if credentials.expired?
      credentials.fetch_access_token!
      user.update(
        access_token: credentials.access_token,
        expires_at: credentials.expires_at,
      )
    end
    credentials
  end
end

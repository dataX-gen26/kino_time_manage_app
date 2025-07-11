class GoogleCalendarService
  def initialize(user)
    @user = user
    @client = Google::Apis::CalendarV3::CalendarService.new
    @client.authorization = client_secrets
  end

  def fetch_events(time_min, time_max)
    refresh_token_if_needed
    
    response = @client.list_events(
      'primary',
      time_min: time_min,
      time_max: time_max,
      single_events: true,
      order_by: 'startTime',
    )
    response.items
  end

  private

  def client_secrets
    secrets = Google::Auth::UserRefreshCredentials.new(
      client_id: Rails.application.credentials.google_oauth2[:client_id],
      client_secret: Rails.application.credentials.google_oauth2[:client_secret],
      scope: ['https://www.googleapis.com/auth/calendar.readonly'],
      additional_parameters: { 'access_type' => 'offline' }
    )
    secrets.update_token!(
      access_token: @user.access_token,
      refresh_token: @user.refresh_token,
      expires_at: @user.expires_at
    ) if @user.access_token.present?
    secrets
  end

  def refresh_token_if_needed
    if @user.access_token.present? && @user.expires_at.present? && Time.current >= @user.expires_at
      begin
        @client.authorization.refresh!
        @user.update!(
          access_token: @client.authorization.access_token,
          expires_at: @client.authorization.expires_at
        )
      rescue Google::Auth::TokenRefreshError => e
        Rails.logger.error("Failed to refresh Google token for user #{@user.id}: #{e.message}")
        # リフレッシュトークンが無効な場合は、ユーザーに再認証を促す必要がある
        raise e # コントローラで補足するために再raise
      end
    end
  end
end
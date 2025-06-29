class AiFeedbackService
  include HTTParty
  base_uri "https://generativelanguage.googleapis.com"

  def initialize(user, date)
    @user = user
    @date = date
    @google_calendar_service = GoogleCalendarService.new(@user)
  end

  def generate_daily_review
    planned_events = fetch_planned_events
    actual_records = fetch_actual_records

    prompt = build_prompt(planned_events, actual_records)
    call_gemini_api(prompt)
  end

  private

  def fetch_planned_events
    events = @google_calendar_service.fetch_events(@date).items
    events.map do |event|
      {
        title: event.summary,
        start: event.start.date_time.present? ? event.start.date_time.strftime("%H:%M") : nil,
        end: event.end.date_time.present? ? event.end.date_time.strftime("%H:%M") : nil,
      }
    end
  rescue => e
    Rails.logger.error "Failed to fetch planned events: #{e.message}"
    []
  end

  def fetch_actual_records
    actuals = @user.actuals.where(start_time: @date.all_day).includes(:category)
    actuals.map do |actual|
      {
        content: actual.content,
        category: actual.category.name,
        start: actual.start_time.strftime("%H:%M"),
        end: actual.end_time.strftime("%H:%M"),
        had_problem: actual.is_problem,
      }
    end
  end

  def build_prompt(planned_events, actual_records)
    <<~PROMPT
      あなたは優秀な生産性向上コンサルタントです。
      以下のデータは、あるユーザーの1日のGoogleカレンダーの予定と、実際に行動した実績の記録です。

      予定:
      #{planned_events.to_json}

      実績:
      #{actual_records.to_json}

      このデータに基づいて、以下の形式でフィードバックとアクションプランを生成してください。

      ## 今日のハイライト
      - 良かった点、計画通りに進んだ点など。

      ## 改善点
      - 計画との乖離、問題フラグが立った点、カテゴリの偏りなど。

      ## 明日へのアクションプラン
      - 具体的な改善行動の提案。
    PROMPT
  end

  def call_gemini_api(prompt)
    api_key = ENV["GEMINI_API_KEY"]
    if api_key.blank?
      raise "GEMINI_API_KEY is not set."
    end

    headers = {
      "Content-Type" => "application/json",
    }

    body = {
      contents: [
        {
          parts: [
            {
              text: prompt,
            },
          ],
        },
      ],
    }.to_json

    response = self.class.post(
      "/v1beta/models/gemini-pro:generateContent?key=#{api_key}",
      headers: headers,
      body: body,
    )

    if response.success?
      response.parsed_response["candidates"][0]["content"]["parts"][0]["text"]
    else
      Rails.logger.error "Gemini API Error: #{response.code} - #{response.body}"
      raise "Failed to get feedback from AI: #{response.body}"
    end
  end
end

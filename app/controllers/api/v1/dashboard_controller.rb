class Api::V1::DashboardController < ApplicationController
  before_action :authenticate_user!

  def summary
    period = params[:period]
    date = params[:date] ? Date.parse(params[:date]) : Date.current

    case period
    when "daily"
      render json: daily_summary(date)
    when "weekly"
      render json: weekly_summary(date)
    when "monthly"
      render json: monthly_summary(date)
    else
      render json: { error: "Invalid period" }, status: :bad_request
    end
  end

  private

  def daily_summary(date)
    actuals = current_user.actuals.where(start_time: date.all_day)
    category_distribution = actuals.group(:category_id).sum("EXTRACT(EPOCH FROM (end_time - start_time))")
    total_duration = category_distribution.values.sum

    formatted_distribution = category_distribution.map do |category_id, duration|
      category = Category.find(category_id)
      {
        category_name: category.name,
        category_color: category.color,
        duration_seconds: duration,
        percentage: total_duration > 0 ? (duration.to_f / total_duration * 100).round(2) : 0
      }
    end

    {
      date: date.to_s,
      total_duration_seconds: total_duration,
      category_distribution: formatted_distribution
    }
  end

  def weekly_summary(date)
    start_of_week = date.beginning_of_week
    end_of_week = date.end_of_week
    actuals = current_user.actuals.where(start_time: start_of_week..end_of_week)

    # カテゴリ別時間配分
    category_distribution = actuals.group(:category_id).sum("EXTRACT(EPOCH FROM (end_time - start_time))")
    total_duration = category_distribution.values.sum
    formatted_category_distribution = category_distribution.map do |category_id, duration|
      category = Category.find(category_id)
      {
        category_name: category.name,
        category_color: category.color,
        duration_seconds: duration,
        percentage: total_duration > 0 ? (duration.to_f / total_duration * 100).round(2) : 0
      }
    end

    # 日別活動時間の推移
    daily_activity = (start_of_week..end_of_week).map do |d|
      daily_actuals = actuals.where(start_time: d.all_day)
      daily_category_distribution = daily_actuals.group(:category_id).sum("EXTRACT(EPOCH FROM (end_time - start_time))")
      {
        date: d.to_s,
        total_duration_seconds: daily_category_distribution.values.sum,
        category_distribution: daily_category_distribution.map do |category_id, duration|
          category = Category.find(category_id)
          {
            category_name: category.name,
            category_color: category.color,
            duration_seconds: duration
          }
        end
      }
    end

    # 生産性指標のトレンド (仮実装)
    productivity_trend = (start_of_week..end_of_week).map do |d|
      daily_actuals = actuals.where(start_time: d.all_day)
      productive_time = daily_actuals.joins(:category).where(categories: { name: ["仕事", "学習"] }).sum("EXTRACT(EPOCH FROM (end_time - start_time))")
      unproductive_time = daily_actuals.joins(:category).where(categories: { name: ["休憩", "浪費"] }).sum("EXTRACT(EPOCH FROM (end_time - start_time))")
      problem_time = daily_actuals.where(is_problem: true).sum("EXTRACT(EPOCH FROM (end_time - start_time))")
      {
        date: d.to_s,
        productive_time_seconds: productive_time,
        unproductive_time_seconds: unproductive_time,
        problem_time_seconds: problem_time
      }
    end

    # 予定 vs 実績の比較 (仮実装)
    plan_vs_actual = (start_of_week..end_of_week).map do |d|
      google_calendar_service = GoogleCalendarService.new(current_user)
      events = google_calendar_service.fetch_events(d).items
      planned_time = events.sum { |event| (event.end.date_time - event.start.date_time).to_i rescue 0 }
      executed_time = actuals.where(start_time: d.all_day).joins(:category).where(categories: { name: ["仕事", "学習"] }).sum("EXTRACT(EPOCH FROM (end_time - start_time))")
      {
        date: d.to_s,
        planned_time_seconds: planned_time,
        executed_time_seconds: executed_time
      }
    end

    {
      start_date: start_of_week.to_s,
      end_date: end_of_week.to_s,
      total_duration_seconds: total_duration,
      category_distribution: formatted_category_distribution,
      daily_activity: daily_activity,
      productivity_trend: productivity_trend,
      plan_vs_actual: plan_vs_actual
    }
  end

  def monthly_summary(date)
    start_of_month = date.beginning_of_month
    end_of_month = date.end_of_month
    actuals = current_user.actuals.where(start_time: start_of_month..end_of_month)

    # カテゴリ別時間配分
    category_distribution = actuals.group(:category_id).sum("EXTRACT(EPOCH FROM (end_time - start_time))")
    total_duration = category_distribution.values.sum
    formatted_category_distribution = category_distribution.map do |category_id, duration|
      category = Category.find(category_id)
      {
        category_name: category.name,
        category_color: category.color,
        duration_seconds: duration,
        percentage: total_duration > 0 ? (duration.to_f / total_duration * 100).round(2) : 0
      }
    end

    # 日別活動時間の推移
    daily_activity = (start_of_month..end_of_month).map do |d|
      daily_actuals = actuals.where(start_time: d.all_day)
      daily_category_distribution = daily_actuals.group(:category_id).sum("EXTRACT(EPOCH FROM (end_time - start_time))")
      {
        date: d.to_s,
        total_duration_seconds: daily_category_distribution.values.sum,
        category_distribution: daily_category_distribution.map do |category_id, duration|
          category = Category.find(category_id)
          {
            category_name: category.name,
            category_color: category.color,
            duration_seconds: duration
          }
        end
      }
    end

    # 生産性指標のトレンド (仮実装)
    productivity_trend = (start_of_month..end_of_month).map do |d|
      daily_actuals = actuals.where(start_time: d.all_day)
      productive_time = daily_actuals.joins(:category).where(categories: { name: ["仕事", "学習"] }).sum("EXTRACT(EPOCH FROM (end_time - start_time))")
      unproductive_time = daily_actuals.joins(:category).where(categories: { name: ["休憩", "浪費"] }).sum("EXTRACT(EPOCH FROM (end_time - start_time))")
      problem_time = daily_actuals.where(is_problem: true).sum("EXTRACT(EPOCH FROM (end_time - start_time))")
      {
        date: d.to_s,
        productive_time_seconds: productive_time,
        unproductive_time_seconds: unproductive_time,
        problem_time_seconds: problem_time
      }
    end

    # 予定 vs 実績の比較 (仮実装)
    plan_vs_actual = (start_of_month..end_of_month).map do |d|
      google_calendar_service = GoogleCalendarService.new(current_user)
      events = google_calendar_service.fetch_events(d).items
      planned_time = events.sum { |event| (event.end.date_time - event.start.date_time).to_i rescue 0 }
      executed_time = actuals.where(start_time: d.all_day).joins(:category).where(categories: { name: ["仕事", "学習"] }).sum("EXTRACT(EPOCH FROM (end_time - start_time))")
      {
        date: d.to_s,
        planned_time_seconds: planned_time,
        executed_time_seconds: executed_time
      }
    end

    {
      start_date: start_of_month.to_s,
      end_date: end_of_month.to_s,
      total_duration_seconds: total_duration,
      category_distribution: formatted_category_distribution,
      daily_activity: daily_activity,
      productivity_trend: productivity_trend,
      plan_vs_actual: plan_vs_actual
    }
  end
end

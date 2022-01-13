class Admin::MetricsController < Admin::ApplicationController
  def index
    @date = Date.current.beginning_of_week

    @metric_weeks = 10.times.map do |i|
      d = (@date - i.weeks)
      acquired_subs = Subscription.where(created_at: d.beginning_of_week.beginning_of_day..d.end_of_week.end_of_day)
      {
        date: d,
        acquisition: acquired_subs.count,
        medium_split: acquired_subs.any? ? (((acquired_subs.includes_print.count.to_f / acquired_subs.count) * 100).round(2)) : nil,
        average_price: acquired_subs.any? ? ((acquired_subs.map(&:mrr).compact.sum) / acquired_subs.count) : nil,
      }
    end

    @metric_months = 10.times.map do |i|
      d = (@date - i.months).beginning_of_month
      acquired_subs = Subscription.where(created_at: d.beginning_of_month.beginning_of_day..d.end_of_month.end_of_day)
      {
        date: d,
        acquisition: acquired_subs.count,
        medium_split: acquired_subs.any? ? (((acquired_subs.includes_print.count.to_f / acquired_subs.count) * 100).round(2)) : nil,
        average_price: acquired_subs.any? ? ((acquired_subs.map(&:mrr).compact.sum) / acquired_subs.count) : nil,
      }
    end
  end
end

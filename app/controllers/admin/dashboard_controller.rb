class Admin::DashboardController < Admin::ApplicationController
  skip_before_action :require_admin, only: [:auto]

  def show
    @current_issue = Issue.current
    @recent_subs = Subscription.where(status: 'active').order('created_at desc').limit(10)
    @in_danger = Subscription.where(status: 'past_due').order('created_at asc').limit(10)
    @shame_mrr = (User.where(sources_count: 0).joins(:subscriptions).merge(Subscription.where(status: 'past_due')).map { |u| u.subscription.mrr }.compact.sum / 100.0)
  end
end

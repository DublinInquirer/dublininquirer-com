class Admin::DashboardController < Admin::ApplicationController
  skip_before_action :require_admin, only: [:auto]

  def show
    @current_issue = Issue.current
    @recent_subs = Subscription.where(status: 'active').order('created_at desc').includes(:user).limit(10)
    @in_danger = Subscription.where(status: 'past_due').order('created_at asc').includes(:user).limit(10)
  end
end

class Admin::DashboardController < Admin::ApplicationController
  skip_before_action :require_admin, only: [:auto]

  def show
    @current_issue = Issue.current
    @recent_subs = Subscription.where(status: 'active').order('created_at desc').limit(10)
    @recent_churns = Subscription.churned.order('ended_at desc').limit(10)
  end
end

class Admin::DashboardController < Admin::ApplicationController
  skip_before_action :require_admin, only: [:auto]

  def show
    @recent_split = Subscription.recent_split_percentage
    @current_issue = Issue.current.articles
    @unapproved_comments = Comment.not_approved.not_spam.created_since(2.weeks.ago)
  end

  def auto
    raise "Not allowed on production" unless Rails.env.development?

    @user = User.admin.first
    auto_login(@user)
    redirect_to [:admin, :root]
  end
end

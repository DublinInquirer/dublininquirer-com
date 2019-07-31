class ApplicationController < ActionController::Base
  impersonates :user
  before_action :set_raven_context, :log_out_deleted_users
  helper_method :current_visitor, :remaining_reads, :read_count, :permission_for_cookie?

  def log_out_deleted_users
    return true unless logged_in?
    return true unless current_user.scheduled_for_deletion?

    logout
    redirect_to :root
  end

  def remaining_reads
    (current_visitor.read_limit - current_visitor.read_count)
  end

  def current_visitor
    @current_visitor ||= find_or_create_current_visitor
  end

  def read_limit
    current_visitor.read_limit
  end

  def read_count
    current_visitor.read_count
  end

  def permission_for_article?(slug)
    return true if logged_in? && current_user.subscriber?
    current_visitor.attempt_to_read(slug)
  end

  def permission_for_cookie?
    return true if logged_in?
    return true if cookies[:accepts_cookies] == 'yes'

    false
  end

  def setup_legacy_account(user)
    user.generate_reset_password_token!
    UserMailer.migrate_account_email(user).deliver_later
    redirect_to :migrate_hold
  end

  private

  def find_or_create_current_visitor
    if cookies.signed[:visitor_id].present?
      visitor = Visitor.find(cookies.signed[:visitor_id])
      return visitor if visitor.present?
    end
    
    visitor = Visitor.create!
    cookies.permanent.signed[:visitor_id] = visitor.id
    return visitor
  end

  def not_authenticated
    redirect_to login_path, alert: "You need to log in."
  end

  def set_raven_context
    if logged_in?
      Raven.user_context(email: current_user.email_address)
      Raven.extra_context(params: params.to_unsafe_h, url: request.url)
    end
  end
end

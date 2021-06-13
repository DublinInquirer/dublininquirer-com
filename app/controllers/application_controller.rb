class ApplicationController < ActionController::Base
  impersonates :user
  before_action :log_out_deleted_users
  helper_method :current_visitor, :remaining_reads, :read_count, :permission_for_cookie?, :newsletter_subscribe_dismissed?

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

  def newsletter_subscribe_dismissed?
    return true if cookies.has_key? 'newsletter_subscribe_dismissed'

    false
  end

  def setup_legacy_account(user)
    user.generate_reset_password_token!
    UserMailer.migrate_account_email(user).deliver_later
    redirect_to :migrate_hold
  end

  def visitor_is_probable_bot?
    return true if cookies.permanent.signed[:probable_bot] == 'true'
    false
  end

  def mark_visitor_as_probable_bot
    (cookies.permanent.signed[:probable_bot] == 'true')
  end

  private

  def find_or_create_current_visitor
    if cookies.signed[:visitor_id].present?
      v = Visitor.where(id: cookies.signed[:visitor_id]).take
      return v if v.present?
    end

    visitor = Visitor.create!
    cookies.permanent.signed[:visitor_id] = visitor.id
    return visitor
  end

  def not_authenticated
    redirect_to login_path, alert: "You need to log in."
  end
end

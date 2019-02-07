class Admin::ApplicationController < ApplicationController
  before_action :require_admin
  layout 'admin'

  private

  def require_admin
    return true if (logged_in? && current_user.is_admin?)
    not_authenticated
  end
end

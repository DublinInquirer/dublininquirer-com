class UserSessionsController < ApplicationController
  before_action :require_login, only: [:destroy]
  skip_before_action :verify_authenticity_token, only: [:accept_cookies]

  layout 'modal'

  def new
    @user = User.new
  end

  def create
    if @user = login(params[:email_address].downcase.strip, params[:password], true)
      if @user.delinquent?
        redirect_to [:payment, :user]
      else
        redirect_back_or_to :root
      end
    else
      @failure = true
      render action: 'new'
    end
  end

  def destroy
    logout
    redirect_to :root
  end

  def accept_cookies
    cookies.permanent[:accepts_cookies] = "yes"
    render plain: 'noted.'
  end
end

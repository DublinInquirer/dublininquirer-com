class PasswordResetsController < ApplicationController
  # skip_before_action :require_login

  layout 'modal'

  def create
    @user = User.find_by(email_address: params[:email_address])
    @user.deliver_reset_password_instructions! if @user
    redirect_to(root_path, notice: 'Instructions have been sent to your email.')
  end

  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end
  end

  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end

    if @user.change_password!(params[:user][:password])
      @user.touch(:set_password_at)
      auto_login(@user, true)
      redirect_to(root_path, notice: 'Your password was successfully updated.')
    else
      render action: "edit"
    end
  end
end

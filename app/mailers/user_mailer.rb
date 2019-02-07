class UserMailer < ApplicationMailer
  def reset_password_email(user)
    @user = User.find user.id
    @url  = edit_password_reset_url(@user.reset_password_token)
    mail(to: @user.email_address,
         subject: "Reset your password")
  end

  def migrate_account_email(user)
    @user = User.find user.id
    @url  = migrate_url(token: @user.reset_password_token)
    mail(to: @user.email_address, subject: "Set up your new Dublin Inquirer account")
  end

  def welcome_email(user_id, subscription_id)
    @user = User.find user_id
    @subscription = Subscription.find subscription_id
    @given_name = @user.given_name

    template_name = if @subscription.plan.is_patron?
      'welcome_patron'
    elsif @subscription.plan.is_friend?
      'welcome_patron'
    elsif @subscription.plan.is_print?
      'welcome_print'
    elsif @subscription.plan.is_digital?
      'welcome_digital'
    else
      raise "No welcome for user: #{ user_id }"
    end

    mail(to: @user.email_address,
         bcc: 'brian+signups@dublininquirer.com',
         subject: "Thanks for subscribing, #{ @given_name }!",
         from: 'Dublin Inquirer <info@dublininquirer.com>',
         template_path: 'user_mailer',
         template_name: template_name
      )
  end
end

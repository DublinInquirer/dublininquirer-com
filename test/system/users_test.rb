require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  test 'paywall w/o account' do
  end

  test 'paywall w/ account' do
  end

  test 'paywall login' do
  end

  test 'paywall register' do
  end

  test 'creating a new user' do
    visit root_url
    assert_selector 'a', text: 'Log in'
    click_link 'Log in', match: :first
    click_link 'Create one now'
    assert_content 'CREATE AN ACCOUNT'

    fill_in 'Email address', with: 'brian@elbow.ie'
    fill_in 'Password', with: 'secret'
    click_button 'Register'

    assert_selector '.concise-nav', text: 'brian@elbow.ie'

    click_link 'brian@elbow.ie'
    click_link 'Log out'

    assert_selector 'a', text: 'Log in'
  end

  test 'reset password' do
    user = create(:user, email_address: 'testing123@localhost')

    visit root_url
    click_link 'Log in', match: :first
    click_link 'Reset it'
    fill_in 'Email address', with: 'testing123@localhost'
    click_button 'Reset'

    reset_mail = ActionMailer::Base.deliveries.last
    assert_equal "Reset your password", reset_mail.subject
    assert_match /password_resets\/(.+)\/edit/, reset_mail.body.to_s
    reset_id = reset_mail.body.to_s.scan(/password_resets\/(.+)\/edit/).first.first

    visit edit_password_reset_path(reset_id)
    assert_content 'SET A NEW PASSWORD'

    fill_in 'Password', with: 'secret'
    click_button 'Save'

    assert_content 'testing123@localhost'
    click_link 'testing123@localhost', match: :first
    click_link 'Log out', match: :first

    click_link 'Log in', match: :first
    fill_in 'email_address', with: 'testing123@localhost'
    fill_in 'password', with: 'secret'
    click_button "Log in"

    assert_selector 'a', text: 'testing123@localhost'
  end
end

require "application_system_test_case"

class SubscriptionsTest < ApplicationSystemTestCase
  test 'subscribing to digital' do
    visit root_url
    click_link 'Subscribe', match: :first
    assert_content 'Subscribe for €8'

    assert_selector 'a', text: 'Subscribe for €5'

    click_link 'Subscribe for €5'

    fill_in 'Email address', with: 'subscriber@localhost.ie'
    fill_in 'Name', with: 'Lois'
    fill_in 'Surname', with: 'Kapila'

    fill_stripe_elements(card: '4242424242424242')

    click_button 'Subscribe'
  end

  def fill_stripe_elements(card: , expiry: '1234', cvc: '123', postal: '12345')
    using_wait_time(4) do
      frame = find('#stripe-form_card-number > div > iframe')
      within_frame(frame) do
        card.to_s.chars.each do |piece|
          find_field('cardnumber').send_keys(piece)
        end
      end

      frame = find('#stripe-form_card-expiry > div > iframe')
      within_frame(frame) do
        expiry.to_s.chars.each do |piece|
          find_field('exp-date').send_keys(piece)
        end
      end

      frame = find('#stripe-form_card-cvc > div > iframe')
      within_frame(frame) do
        cvc.to_s.chars.each do |piece|
          find_field('cvc').send_keys(piece)
        end
      end
    end
  end
end


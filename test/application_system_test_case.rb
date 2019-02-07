require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1440, 900], options: { args: %w[headless disable-gpu] }

  def setup
    StripeSetterUp.setup_products
    StripeSetterUp.setup_plans
  end

  def teardown
    page.driver.browser.manage.logs.get(:browser).each do |log|
      case log.message
      when /This page includes a password or credit card input in a non-secure context/,
           /Failed to load resource/, /has been blocked by CORS policy/
        next
      else
        message = "[#{log.level}] #{log.message}"
        if log.level == 'SEVERE'
          raise message
        else
          warn message
        end
      end
    end
  end
end

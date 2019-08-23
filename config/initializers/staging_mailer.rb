if ENV['PRODUCTION_ENVIRONMENT'] && (ENV['PRODUCTION_ENVIRONMENT'].to_sym == :staging)
  class ChangeStagingEmailDestination
    def self.delivering_email(mail)
      mail.to = "inquirer+staging@civictech.ie"
      mail.subject = "[STAGING] " + mail.subject
    end
  end
  ActionMailer::Base.register_interceptor(ChangeStagingEmailDestination)
end

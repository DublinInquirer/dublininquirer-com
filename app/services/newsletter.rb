require 'digest'

class Newsletter
  def self.upsert_subscriber(user)
    mc = Gibbon::Request.new
    email_hash = Digest::MD5.hexdigest(user.email_address.downcase)
    mc.lists(Rails.application.credentials.dig(ENV['PRODUCTION_ENVIRONMENT'].to_sym, :mailchimp, :list_id)).members(email_hash).upsert(body: {
        email_address: user.email_address,
        status: "subscribed",
        merge_fields: {FNAME: user.given_name, LNAME: user.surname}
      })
  end
end
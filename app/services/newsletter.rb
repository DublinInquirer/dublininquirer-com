require 'digest'

class Newsletter
  LIST_ID = Rails.application.credentials.dig(ENV['PRODUCTION_ENVIRONMENT'].to_sym, :mailchimp, :list_id)

  def self.upsert_subscriber(user)
    mc = Gibbon::Request.new
    email_hash = Digest::MD5.hexdigest(user.email_address.downcase)
    mc
      .lists(
        LIST_ID
      )
      .members(email_hash)
      .upsert(
        body: {
          email_address: user.email_address,
          status: 'subscribed',
          merge_fields: {
            FNAME: user.given_name,
            LNAME: user.surname,
          },
        },
      )
  end

  def self.sync_from_mailchimp!
    page_size = 50
    page = 0
    still_fetching = true

    while still_fetching do
      members = Gibbon::Request
        .lists(LIST_ID)
        .members
        .retrieve(params: {
          "fields": "members.email_address,members.id,members.merge_fields,members.status",
          "count": page_size.to_s,
          "offset": (page_size * page).to_s
        })
        .body[:members]

      still_fetching = members.length == page_size

      members.each do |member|
        Newsletter.upsert_from_mailchimp!(member)
      end

      page += 1
    end
  end

  def self.upsert_from_mailchimp!(member)
    subscriber = NewsletterSubscriber.find_or_initialize_by(mailchimp_id: member[:id])
    subscriber.email_address = member[:email_address]
    subscriber.given_name = member[:merge_fields][:FNAME]
    subscriber.surname = member[:merge_fields][:LNAME]
    subscriber.status = member[:status]
    subscriber.save!
  end
end
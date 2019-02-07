class LandingPage < ApplicationRecord
  validates :slug, presence: true, uniqueness: true

  before_validation :normalise_slug

  def to_param
    self.slug
  end

  def subscriptions
    @subscriptions ||= Subscription.where(landing_page_slug: self.slug)
  end

  private

  def normalise_slug
    self.slug = self.slug.try(:downcase).try(:strip)
  end
end
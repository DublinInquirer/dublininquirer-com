require 'open-uri'

class Artwork < ApplicationRecord
  mount_uploader :image, ImageUploader

  validates :wp_file, uniqueness: true, allow_nil: true
  validates :hashed_id, presence: true, uniqueness: true
  validates :image, presence: true

  before_validation :set_hashed_id, if: -> (m) { m.hashed_id.blank? }

  belongs_to :article, optional: true

  has_many :featured_articles, class_name: 'Article', foreign_key: 'featured_artwork_id'

  def to_param
    self.hashed_id
  end

  def element
    "<artwork id='#{ self.hashed_id }'></artwork>"
  end

  def rendered_element
    "<figure class='artwork #{ self.portrait? ? '-portrait' : nil }'><img src='#{ self.image.massive.url }' />#{ self.rendered_caption }</figure>"
  end

  def rendered_caption
    if caption.present?
      "<figcaption>#{ caption }</figcaption>"
    else
      ""
    end
  end

  def portrait?
    return false unless self.height_px && self.width_px
    (self.height_px > self.width_px)
  end

  def self.searchable_columns
    [:caption]
  end

  private

  def set_hashed_id
    self.hashed_id = SecureRandom.hex(8)
  end
end

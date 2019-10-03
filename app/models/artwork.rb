require 'open-uri'

class Artwork < ApplicationRecord
  mount_uploader :image, ImageUploader

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
    "<figure class='artwork #{ self.portrait? ? '-portrait' : nil }'><img src='#{ self.image.medium.url }' />#{ self.rendered_caption }</figure>"
  end

  def rendered_caption
    if caption.present?
      "<figcaption>#{ caption }</figcaption>"
    else
      ""
    end
  end

  def file_type
    return nil unless self.image.present? && self.image.file.present?
    return 'image/jpeg' if (image.file.to_s.include?('.jpg') or image.file.to_s.include?('.jpeg'))
    return 'image/gif' if (image.file.to_s.include?('.gif'))
    return 'image/png' if (image.file.to_s.include?('.png'))
    nil
  end
  
  def medium_width_px
  end
  
  def medium_height_px
  end

  def large_width_px # 1600^2
    return nil unless height_px && width_px
    return 1600 if !self.portrait? # lol

    ((1600.0/height_px) * width_px).round
  end

  def large_height_px # 1600^2
    return nil unless height_px && width_px
    return 1600 if self.portrait? # lol

    ((1600.0/width_px) * height_px).round
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

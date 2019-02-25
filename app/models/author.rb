class Author < ApplicationRecord
  mount_uploader :portrait, PortraitUploader

  has_many :article_authors, dependent: :destroy
  has_many :articles, through: :article_authors

  validates :full_name, presence: true
  validates :slug, uniqueness: true

  after_validation :generate_slug

  scope :by_name, -> { order('full_name asc') }

  def to_param
    self.slug_was
  end

  def authored_articles
    Article.by_author(self)
  end

  def given_name
    namae = Namae.parse(self.full_name).first

    return nil unless namae.present?

    namae['given']
  end

  def self.attempt_to_find_by_slug(slug)
    a = where(slug: slug).first
    return a if a.present?

    a = where('slug LIKE ?', "#{ slug }%").first
    return a if a.present?

    nil
  end

  def self.searchable_columns
    [:full_name, :bio]
  end

  private

  def generate_slug
    slug_matches = self.class.where(slug: full_name.parameterize).where.not(id: self.id)
    self.slug = if slug_matches.any?
      full_name.parameterize + "-#{ slug_matches.count + 1 }"
    else
      full_name.parameterize
    end
  end
end

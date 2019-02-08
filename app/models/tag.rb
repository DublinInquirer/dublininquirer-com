class Tag < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :slug, uniqueness: true

  after_validation :generate_slug
  before_destroy :remove_from_articles

  scope :by_name, -> { order('name asc') }

  def to_param
    self.slug_was
  end

  def articles
    @articles ||= Article.in_tag(self)
  end

  def self.searchable_columns
    [:name, :slug]
  end

  private

  def generate_slug
    self.slug = self.name.parameterize
  end

  def remove_from_articles
    articles.each do |article|
      article.update(tag_ids: article.tag_ids - [self.id])
    end
  end
end
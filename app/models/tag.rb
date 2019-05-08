class Tag < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :slug, uniqueness: true

  after_validation :generate_slug
  after_save :add_to_articles, if: :saved_change_to_name?
  before_destroy :remove_from_articles

  scope :by_name, -> { order('name asc') }
  scope :autolinkable, -> { where(autolink: true) }

  def to_param
    self.slug_was
  end

  def articles
    @articles ||= Article.in_tag(self)
  end

  def self.searchable_columns
    [:name, :slug]
  end

  def merge_into!(destination_tag)
    raise "Can't merge into nil" unless destination_tag && destination_tag.id
    articles.each do |article|
      article.update(tag_ids: article.tag_ids - [self.id] + [destination_tag.id])
    end
    self.destroy!
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

  def add_to_articles
    return true unless self.autolink?

    self.articles.each do |article|
      article.update(tag_ids: article.tag_ids - [self.id])
    end
    
    Article.basic_search(self.name).each do |article|
      next if article.tag_ids.include?(self.id) # do this in pg in the line above
      article.update(tag_ids: (article.tag_ids + [self.id]))
    end

    true
  end
end
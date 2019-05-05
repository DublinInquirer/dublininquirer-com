class Tag < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :slug, uniqueness: true

  after_validation :generate_slug
  after_save :autolink_articles
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

  def merge_into!(destination_tag)
    articles.each do |article|
      article.update(tag_ids: article.tag_ids - [self.id] + [destination_tag.id])
    end
    self.destroy!
  end

  private

  def autolink_articles
    return true unless self.autolink?

    Article.basic_search(self.name).each do |article|
      article.tag_ids << self.id

      article.content = article.content.gsub /#{self.name}/i, '<a class="autolink" href="/tags/' + self.slug + '">\&</a>'

      article.save
    end
  end

  def generate_slug
    self.slug = self.name.parameterize
  end

  def remove_from_articles
    articles.each do |article|
      article.update(tag_ids: article.tag_ids - [self.id])
    end
  end
end
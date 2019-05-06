class Tag < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :slug, uniqueness: true

  after_validation :generate_slug
  before_destroy :remove_from_articles

  scope :by_name, -> { order('name asc') }
  scope :autolinkable, -> { where(autolink: true) }

  def self.remove_hard_autolinks
    autolinkable.each do |tag|
      tag.articles.each do |article|
        ng_content = Nokogiri::HTML.fragment(article.content)
        ng_content.css('a.autolink').each do |autolink_tag|
          if autolink_tag.present? && autolink_tag.text.present?
            autolink_tag.replace autolink_tag.text
          end
        end
        article.update!(content: ng_content)
      end
    end
  end

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

  def generate_slug
    self.slug = self.name.parameterize
  end

  def remove_from_articles
    articles.each do |article|
      article.update(tag_ids: article.tag_ids - [self.id])
    end
  end
end
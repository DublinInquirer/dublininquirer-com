require 'sanitize'

class Article < ApplicationRecord
  TEMPLATES = %w(standard opinion illustration stack podcast legacy)
  CATEGORIES = %w(the-dish unreal-estate city-desk culture-desk opinion fiction podcast cover cartoon a-quick-note)

  validates :title, presence: true, uniqueness: { scope: :issue }
  validates :slug, uniqueness: true
  validates :template, inclusion: { in: TEMPLATES }
  validates :category, inclusion: { in: CATEGORIES }, on: :create

  belongs_to :issue, optional: true, touch: true
  belongs_to :featured_artwork, class_name: 'Artwork', foreign_key: 'featured_artwork_id', optional: true

  has_many :artworks, dependent: :nullify
  has_many :comments, dependent: :delete_all

  has_many :article_authors, dependent: :destroy
  has_many :authors, through: :article_authors

  after_initialize :clean_text_fields
  before_validation :sanitize_html, :uniq_tags, :generate_slug, :generate_text, :uniq_slugs
  before_save :format_common_hacks
  before_save :attach_tags, if: :will_save_change_to_text?

  paginates_per 8

  scope :by_title, -> { order('title asc') }
  scope :by_position, -> { order('position asc') }
  scope :by_date, -> { includes(:issue).order('issues.issue_date desc') }

  scope :by_author, -> (a) { joins(:article_authors).merge(ArticleAuthor.where(author_id: a.id)) }
  scope :published, -> { joins(:issue).merge( Issue.published ) }
  scope :in_category, -> (c) { where(category: c.downcase) }
  scope :not_in_category, -> (c) { where.not(category: c.downcase) }
  scope :in_tag, -> (t) { t ? where('tag_ids @> ?', "{#{ t.id }}") : none }
  scope :not_in_tag, -> (t) { t ? where.not('tag_ids @> ?', "{#{ t.id }}") : all }
  scope :by_slug, -> (s) { where('former_slugs @> ?', "{#{ s.downcase }}") }
  scope :standard, -> { not_in_category('cover').not_in_category('cartoon') }

  def path # it would be cool if this worked for unpersisted
    @path ||= self.slug ? self.slug_was : self.slug_will_be
  end

  def from_the_same_issue
    return nil unless self.issue.present?
    @same_issue ||= self.issue.articles.includes(:authors, :artworks).where.not(id: self.id)
  end

  def published_on
    return nil unless self.issue
    return Date.new(2021,4,1) if (self.id.to_i == 3044)
    self.issue.issue_date
  end

  def author
    @author ||= authors.last
  end

  def author_ids
    self.authors.map(&:id)
  end

  def author_ids=(a_ids)
    a_ids = a_ids.compact.reject(&:blank?)

    article_authors.each do |article_author|
      if a_ids.include?(article_author.author.id)
        a_ids.delete(article_author.author.id)
      else
        article_author.destroy!
      end
    end

    a_ids.each { |a_id| article_authors.create!(author_id: a_id) }
  end

  def excerpt_markdown
    return nil unless self.excerpt.present?
    @excerpt_markdown ||=ReverseMarkdown.convert(self.excerpt.strip)
  end

  def excerpt_markdown=(str)
    self.excerpt = Kramdown::Document.new(str).to_html
  end

  def content_markdown
    return nil unless self.content.present?
    @content_markdown ||= ReverseMarkdown.convert(self.content.strip)
  end

  def content_markdown=(str)
    self.content = Kramdown::Document.new(str).to_html
  end

  def opinion_title
    self.title.gsub(/(.+): /, '').strip
  end

  def word_count
    text.split.size
  end

  def reading_time
    (word_count / 275.0).ceil
  end

  def paywalled?
    !not_paywalled?
  end

  def not_paywalled?
    %w(cover podcast cartoon cycle-collision-tracker a-quick-note).include?(self.category)
  end

  def is_published?
    return false unless self.issue
    self.issue.published
  end

  def status
    is_published? ? 'published' : 'draft'
  end

  def commentable?
    return false if (self.category == 'cartoon')
    return false if (self.category == 'cover')
    return true
  end

  def referenced_artworks
    hashed_ids = []
    ng_content = Nokogiri::HTML.fragment(self.content)
    hashed_ids = ng_content.css('artwork').map do |artwork_el|
      artwork_el['id'].to_s
    end

    Artwork.where(hashed_id: hashed_ids)
  end

  def issue_date
    return nil unless self.issue
    return self.issue.issue_date
  end

  def tags
    @tags ||= Tag.where(id: self.tag_ids)
  end

  def displayable_tags
    @displayable_tags ||= self.tags.where(displayable: true)
  end

  def slug_will_be
    slug = title.downcase.parameterize
    date_slug = if self.issue_date.present?
      issue_date.strftime('%Y/%m/%d')
    else
      'drafts'
    end

    "/#{ date_slug }/#{ slug }"
  end

  def self.searchable_columns
    [:title, :excerpt, :text, :category]
  end

  def self.template_options
    TEMPLATES
  end

  def self.category_options
    CATEGORIES.map { |c| [c.gsub("-", " "), c] }
  end

  private

  def generate_text
    self.text = Nokogiri::HTML.fragment(content).text
  end

  def sanitize_html
    self.content = Sanitize.fragment(content,
      elements: %w(img h1 h2 h3 h4 h5 p ul ol li strong em b i a artwork podcast video source figure figcaption table thead tbody tr td th iframe hr script div),
      attributes: {
        'script' => %w(id src type),
        'artwork' => %w(id),
        'podcast' => %w(src),
        'video' => %w(autoplay loop muted controls),
        'source' => %w(src type),
        'p' => %w(id class),
        'ol' => %w(id class),
        'ul' => %w(id class),
        'a' => %w(id class href),
        'img' => %w(src alt width height class),
        'iframe' => %w(src width height class frameborder allowfullscreen id),
        'div' => %w(id class data-src)
      }
    )

    self.excerpt = Sanitize.fragment(excerpt,
      elements: %w(strong em b i a),
      attributes: {
        'a' => %w(href)
      }
    )
  end

  def replace_external_images
    self.content = Artwork.replace_images(self.content)
  end

  def format_common_hacks
    self.content = self.content.gsub('***','<hr class="-separator"></hr>').
                     gsub('* * *','<hr class="-separator"></hr>').
                     gsub('<p class="section-separator">***</p>','<hr class="-separator"></hr>')
  end

  def uniq_categories
    self.categories = self.categories.uniq.map(&:downcase)
  end

  def uniq_tags
    self.tag_ids = self.tag_ids.try(:uniq)
  end

  def attach_tags
    # rm existing autolinks
    self.tag_ids = self.tag_ids - self.tags.autolinkable.pluck(:id)

    # add any applicable autolinks
    normalised_text = self.text.downcase
    Tag.autolinkable.pluck(:id, :name).each do |tag_id, tag_name|
      next unless normalised_text.include?(tag_name.downcase)
      self.tag_ids = (self.tag_ids << tag_id)
    end

    self.tag_ids = self.tag_ids.try(:uniq)
  end

  def uniq_slugs
    self.former_slugs = (self.former_slugs << self.slug).uniq.compact.map(&:downcase)
  end

  def generate_slug
    self.slug = self.slug_will_be
  end

  def clean_text_fields
    self.content = self.content.try(:strip)
    self.excerpt = self.excerpt.try(:strip)
    self.title = self.title.try(:strip)
  end
end

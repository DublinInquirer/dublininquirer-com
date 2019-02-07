class Issue < ApplicationRecord
  validates :issue_date, uniqueness: true, presence: true

  scope :published, -> { where(published: true) }

  has_many :articles

  after_save :touch_articles

  validate :is_wednesday

  paginates_per 12

  def to_param
    self.issue_date.to_s
  end

  def standard_articles
    self.articles.standard.by_position
  end

  def month
    self.issue_date.strftime('%B')
  end

  def featured_article
    standard_articles.by_position.first
  end

  def self.current
    where(published: true).order('issue_date desc').first
  end

  def self.create_all_for_articles
    Article.pluck(:issue_date).uniq.each do |issue_date|
      i = find_or_create_by(issue_date: issue_date.to_date)
      i.published = (issue_date < Date.current)
      i.save!
    end
  end

  private

  def touch_articles
    articles.update_all(updated_at: Time.zone.now)
  end

  def is_wednesday
    return false unless self.issue_date
    if !issue_date.wednesday?
      errors.add(:issue_date, "is not a Wednesday")
    end
  end
end

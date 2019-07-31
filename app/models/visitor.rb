class Visitor < ApplicationRecord
  belongs_to :user, optional: true

  def read_article!(slug)
    self.viewed_articles = articles_array << {
      'date': Date.current,
      'slug': slug
    }
    save!
  end

  def attempt_to_read(slug)
    if articles_array.map { |a| a['slug'] }.include?(slug)
      return true # already read
    elsif self.read_count < self.read_limit
      read_article!(slug) # not read, but is now
    else
      return false # not read, can't be
    end
  end

  def read_count
    @read_count ||= articles_array.reject do |viewed_article|
      viewed_article['date'].nil? or
      (Date.parse(viewed_article['date']).beginning_of_day < 1.month.ago)
    end.count
  end

  def read_limit
    self.user.present? ? 4 : 3
  end

  def articles_array
    viewed_articles.present? ? viewed_articles : []
  end
end

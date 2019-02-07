class ChangePodcastCategory < ActiveRecord::Migration[5.2]
  def change
    Article.in_category('podcasts').find_each do |article|
      article.update(category: 'podcast', template: 'podcast')
    end

    Article.in_category('cartoon').find_each do |article|
      article.update(category: 'cartoon', template: 'illustration')
    end

    Article.in_category('cover').find_each do |article|
      article.update(category: 'cover', template: 'illustration')
    end

    Article.in_category('opinion').find_each do |article|
      article.update(category: 'opinion', template: 'opinion')
    end
  end
end

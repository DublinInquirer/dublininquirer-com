namespace :articles do
  task assign_issues: :environment do
    date = Date.new(2015,1,7)

    Article.in_tag('in-print').each do |article|
      article.destroy!
    end

    Article.in_category('in-print').each do |article|
      article.destroy!
    end

    Article.basic_search('subscribers-only').each do |article|
      next if article.title.downcase.include? 'facebook changes challenge'
      article.destroy!
    end

    while date < (Date.current + 1.month) do
      Article.from_issue(date).each do |article|
        article.issue_date = date
        article.save!
      end

      date = (date + 1.week).to_date
    end
  end

  task add_artworks: :environment do
    Article.all.includes(:issue).order('issues.issue_date asc').each do |article|
      if article.featured_artwork.present?
        article.artworks << article.featured_artwork
      end

      article.referenced_artworks.each do |artwork|
        article.artworks << artwork
      end

      article.save!
    end
  end

  task guess_categories: :environment do
    Article.where(category: nil).each do |article|
      article.category = article.categories.first
      article.save!
    end
  end
end

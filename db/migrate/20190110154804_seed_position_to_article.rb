class SeedPositionToArticle < ActiveRecord::Migration[5.2]
  def change
    weights = {
      'city-desk' => 0,
      'unreal-estate' => 0,
      'culture-desk' => 5,
      'fiction' => 10,
      'the-dish' => 6,
      'premium' => 0,
      'vacancy' => 0,
      'films-reviewed' => 6,
      'looking-back-at-2017' => 6,
      'on-the-media' => 10,
      'ask-roe' => 8,
      'opinion' => 10,
      'cartoons' => 20,
      'social-housing' => 0,
      'podcasts' => 10,
      'renting' => 0,
      'affordable-housing' => 0,
      'lihaf' => 0,
      'andy-on-economics' => 10,
      'special-ops' => 0,
      'covers' => 20,
      'ask-emma' => 10,
      'books-reviewed' => 10,
      'brushing-up' => 5,
      'david-on-transport' => 10,
      'ge16-candidates' => 0,
      'frank-unleashed' => 10,
      'music-at-marrowbone-books' => 10,
      'behind-the-scenes' => 5,
      'members-area' => 0,
      'a-quick-note' => 20,
      'curios-about' => 5,
      'joe-on-white-collar-crime' => 10,
      'longreads' => 0,
      'republic-of-data' => 0,
      'cycle-collision-tracker' => 2,
      'most-read-in-2015' => 2,
      'the-write-life' => 10,
      'get-involved' => 10,
      'ui-cadhain-prize' => 10,
      'dublin-superheroes-edition' => 5,
      'journalism-course' => 20,
      'test' => 20,
      'feeding-regeneration' => 0,
      'news-extra' => 0,
      'quizzes' => 20,
      'featured' => 0
    }

    Issue.find_each do |issue|
      issue.articles.order('featured desc').each_with_index do |article, index|
        position = index

        if article.is_featured?
          position = 0
        else
          article.categories.each do |c|
            if weights[c].nil?
              raise c
            end
            if position.nil?
              raise issue.issue_date.to_s
            end
            position += weights[c]
          end
        end

        article.update_column(:position, position)
      end
    end
  end
end

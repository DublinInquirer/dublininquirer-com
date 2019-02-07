class FindCartoons < ActiveRecord::Migration[5.2]
  def change
    Article.basic_search(title: 'cartoon').each do |article|
      article.update_column(:category, 'cartoon')
    end
    Article.in_category('covers').each do |article|
      full_name = article.title.scan(/Issue \d*: By (.+)$/i).first.try(:first)
      if full_name.present?
        author = Author.find_or_create_by!(full_name: full_name)
        article.update_column(:author_ids, [author.id])
        article.update_column(:category, 'cover')
      else
        raise article.inspect
      end
    end
  end
end

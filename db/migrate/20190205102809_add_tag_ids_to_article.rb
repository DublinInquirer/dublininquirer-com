class AddTagIdsToArticle < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :tag_ids, :bigint, array: true, default: []
    add_index :articles, :tag_ids, unique: false

    Article.find_each do |article|
      tag_ids = article.categories.map do |category_str|
        t = Tag.find_or_create_by! name: category_str.gsub('-',' ').capitalize
        t.id
      end
      tag_ids += article.tags.map do |tag_str|
        t = Tag.find_by!(slug: tag_str)
        t.id
      end
      article.update!(tag_ids: tag_ids)
    rescue
      raise "#{ article.slug }: #{ article.category }"
    end

    Tag.find_each do |tag|
      tag.update! displayable: (tag.articles.count > 2)
    end
  end
end

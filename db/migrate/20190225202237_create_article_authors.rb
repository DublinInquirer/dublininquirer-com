class CreateArticleAuthors < ActiveRecord::Migration[5.2]
  def change
    create_table :article_authors do |t|
      t.references :article
      t.references :author

      t.timestamps
    end

    Author.all.find_each do |author|
      author.authored_articles.each do |article|
        ArticleAuthor.create!(author: author, article: article)
      end
    end
  end
end

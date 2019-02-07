class CreateArticles < ActiveRecord::Migration[5.2]
  def change
    create_table :articles do |t|
      t.text :title, null: false
      t.text :slug, null: false
      t.text :excerpt
      t.text :content
      t.text :text
      t.text :tags, array: true, default: []
      t.bigint :author_ids, array: true, default: []
      t.datetime :published_at

      t.timestamps
    end

    add_index :articles, :slug, unique: true
    add_index :articles, :published_at, unique: false
    add_index :articles, :author_ids, unique: false
  end
end

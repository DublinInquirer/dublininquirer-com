class CreateTags < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.text :name, unique: true
      t.text :slug, unique: true
      t.boolean :displayable, default: true

      t.timestamps
    end

    add_index :tags, :name, unique: true
    add_index :tags, :slug, unique: true

    Article.pluck(:tags).flatten.uniq.each do |tag_str|
      next unless tag_str.present?
      Tag.create! name: tag_str.gsub('-',' ').capitalize, slug: tag_str.parameterize
    end
  end
end
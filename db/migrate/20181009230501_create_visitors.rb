class CreateVisitors < ActiveRecord::Migration[5.2]
  def change
    create_table :visitors do |t|
      t.json :viewed_articles, default: {}
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end

class CreateElectionSurveys < ActiveRecord::Migration[5.2]
  def change
    create_table :election_surveys do |t|
      t.text :slug
      t.text :election_type
      t.integer :election_year

      t.timestamps
    end

    add_index :election_surveys, :slug, unique: true
    add_index :election_surveys, :election_type, unique: false
    add_index :election_surveys, :election_year, unique: false
  end
end

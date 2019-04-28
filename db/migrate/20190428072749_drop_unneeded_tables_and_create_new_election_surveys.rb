class DropUnneededTablesAndCreateNewElectionSurveys < ActiveRecord::Migration[5.2]
  def change
    drop_table 'election_survey_responses'
    drop_table 'election_survey_questions'
    drop_table 'election_candidates'
    drop_table 'election_surveys'

    create_table :election_surveys do |t|
      t.text :slug
      t.text :election_type
      t.integer :election_year
      t.jsonb :candidates, null: false, default: {}
      t.jsonb :responses, null: false, default: {}
      t.jsonb :questions, null: false, default: {}
      t.jsonb :parties, null: false, default: {}
      t.jsonb :candidates, null: false, default: {}
      t.jsonb :areas, null: false, default: {}

      t.timestamps
    end

    add_index :election_surveys, :slug, unique: true
    add_index :election_surveys, :election_type, unique: false
    add_index :election_surveys, :election_year, unique: false
    add_index :election_surveys, :candidates, using: :gin
    add_index :election_surveys, :questions, using: :gin
    add_index :election_surveys, :parties, using: :gin
    add_index :election_surveys, :areas, using: :gin
  end
end

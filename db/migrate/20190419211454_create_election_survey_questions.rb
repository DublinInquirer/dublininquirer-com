class CreateElectionSurveyQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :election_survey_questions do |t|
      t.references :election_survey, foreign_key: true
      t.text :slug
      t.text :body
      t.integer :position

      t.timestamps
    end

    add_index :election_survey_questions, [:slug, :election_survey_id], unique: true, name: 'election_survey_questions_slug'
    add_index :election_survey_questions, [:position, :election_survey_id], unique: true, name: 'election_survey_questions_position'
    execute "create index election_survey_questions_body on election_survey_questions using gin(to_tsvector('english', body))"
  end
end

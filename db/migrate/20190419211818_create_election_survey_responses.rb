class CreateElectionSurveyResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :election_survey_responses do |t|
      t.references :election_survey_question, foreign_key: true
      t.text :body
      t.references :election_candidate, foreign_key: true

      t.timestamps
    end

    execute "create index election_survey_responses_full_name on election_survey_responses using gin(to_tsvector('english', body))"
  end
end

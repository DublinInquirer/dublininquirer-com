class CreateElectionCandidates < ActiveRecord::Migration[5.2]
  def change
    create_table :election_candidates do |t|
      t.text :full_name
      t.text :slug
      t.references :election_survey, foreign_key: true
      t.text :area_name
      t.text :party_name
      t.text :council_tracker_slug

      t.timestamps
    end

    add_index :election_candidates, [:slug, :election_survey_id], unique: true, name: 'election_candidates_slug' 
    add_index :election_candidates, :area_name
    add_index :election_candidates, :party_name
    add_index :election_candidates, :council_tracker_slug
    execute "create index election_candidates_full_name on election_candidates using gin(to_tsvector('english', full_name))"
  end
end

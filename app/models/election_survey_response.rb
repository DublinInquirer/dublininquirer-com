class ElectionSurveyResponse < ApplicationRecord
  belongs_to :election_survey_question
  belongs_to :election_candidate
  delegate :election_survey, to: :election_survey_question_id
  
  validates :body, presence: true
end
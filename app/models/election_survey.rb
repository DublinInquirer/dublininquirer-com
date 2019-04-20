class ElectionSurvey < ApplicationRecord
  has_many :election_candidates
  has_many :election_survey_questions
  has_many :election_survey_responses, through: :election_survey_questions

  validates :slug, uniqueness: true
  validates :election_year, presence: true
  validates :election_type, presence: true

  before_save :generate_slug

  def to_param
    self.slug
  end

  private

  def generate_slug
    self.slug = [election_year.to_s, election_type].compact.join.parameterize
  end
end
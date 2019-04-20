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

  def title
    [election_year.to_s, election_type.to_s.try(:capitalize)].compact.join(' ')
  end

  private

  def generate_slug
    self.slug = self.title.parameterize
  end
end
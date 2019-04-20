class ElectionSurveyQuestion < ApplicationRecord
  belongs_to :election_survey
  has_many :election_survey_responses
  has_many :election_canidates, through: :election_survey_responses

  validates :slug, presence: true, uniqueness: true
  validates :body, presence: true

  before_save :format_slug

  def to_param
    self.slug
  end

  private

  def format_slug
    self.slug = self.slug.try(:parameterize)
  end
end
class ElectionSurveyQuestion < ApplicationRecord
  belongs_to :election_survey
  has_many :election_survey_responses, dependent: :destroy
  has_many :election_canidates, through: :election_survey_responses

  validates :slug, uniqueness: true
  validates :body, presence: true

  before_save :format_slug

  def to_param
    self.slug
  end

  private

  def format_slug
    self.slug = if self.slug.blank?
      [
        self.position,
        (self.body.split(' ').first(4).join('-'))
      ].join('-').downcase.parameterize
    else
      self.slug.try(:parameterize)
    end
  end
end
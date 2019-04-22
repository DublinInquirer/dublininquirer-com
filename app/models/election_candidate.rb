class ElectionCandidate < ApplicationRecord
  belongs_to :election_survey
  has_many :election_survey_responses, dependent: :destroy
  has_many :election_survey_questions, through: :election_survey_responses

  validates :full_name, presence: true
  validates :slug, uniqueness: true
  validates :party_name, presence: true
  validates :area_name, presence: true
  validates :council_tracker_slug, uniqueness: true, allow_blank: true

  before_save :generate_slug

  def to_param
    self.slug
  end

  private

  def generate_slug
    self.slug = self.full_name.try(:parameterize)
  end
end

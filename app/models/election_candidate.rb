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

  PARTIES = {
    "labour-party" => "Labour Party",
    "fianna-fail" => "Fianna Fáil",
    "republican-sinn-fein" => "Republican Sinn Féin",
    "fine-gael" => "Fine Gael",
    "independent" => "Independent",
    "labour" => "Labour",
    "green-party" => "Green Party",
    "sinn-fein" => "Sinn Féin",
    "people-before-profit" => "People Before Profit",
    "social-democrats" => "Social Democrats",
    "eirigi" => "Éirígí",
    "solidarity" => "Solidarity",
    "workers-party" => "Workers\' Party",
    "independent-left" => "Independent Left" 
  }

  AREAS = {
    "pembroke" => "Pembroke",
    "ballyfermot-drimnagh" => "Ballyfermot-Drimnagh",
    "ballymun-finglas" => "Ballymun-Finglas",
    "north-inner-city" => "North Inner-City",
    "south-west-inner-city" => "South-West Inner City",
    "cabra-glasnevin" => "Cabra-Glasnevin",
    "clontarf" => "Clontarf",
    "kimmage-rathmines" => "Kimmage-Rathmines",
    "south-east-inner-city" => "South-East Inner-City",
    "artane-whitehall" => "Artane-Whitehall",
    "donaghmede" => "Donaghmede"
  }

  def to_param
    self.slug
  end

  private

  def generate_slug
    self.slug = self.full_name.try(:parameterize)
  end
end

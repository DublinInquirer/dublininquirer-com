module Admin::ElectionSurveysHelper
  def election_year_options
    10.times.map do |i|
      (Date.current + (5 - i).years).year
    end.reverse
  end
end

require 'roo'

class ElectionSurveyImporter
  # CSV_COLS = [:timestamp, :email, :full_name, :party_name, :area_name]

  def self.csv_to_params(survey, file)
    sheet = Roo::CSV.new(file.path, csv_options: {skip_blanks: true, encoding: "utf-8"})

    if valid_survey_csv?(sheet)
      destroy_children(survey)
      create_questions_from_sheet(survey, sheet)
      create_candidates_from_sheet(survey, sheet)
      create_responses_from_sheet(survey, sheet)
    end
  end

  private

  def self.destroy_children(survey)
    survey.election_candidates.destroy_all
    survey.election_survey_questions.destroy_all
    survey.election_survey_responses.destroy_all
  end

  def self.create_candidates_from_sheet(survey, sheet)
    sheet.drop(1).each do |row|
      full_name, party_name, area_name = row[2..4]
      c = survey.election_candidates.create!(full_name: full_name, area_name: area_name, party_name: party_name)
    end
  end

  def self.create_questions_from_sheet(survey, sheet)
    sheet.row(1).drop(5).each do |question|
      pos, body = question.scan(/(\d+). (.+?)$/).first
      q = survey.election_survey_questions.create!(position: pos, body: body)
    end
  end

  def self.create_responses_from_sheet(survey, sheet)
    sheet.drop(1).each do |row|
      # this won't work consistently if there's any formatting of names
      candidate = survey.election_candidates.find_by(full_name: row[2])
      row.drop(5).each_with_index do |response, i|
        next if response.blank?
        # TODO hacky
        pos = sheet.row(1).drop(5)[i].scan(/(\d+). (.+?)$/).first.first.to_i
        question = survey.election_survey_questions.find_by(position: pos)
        question.election_survey_responses.create!(body: response, election_candidate: candidate)
      end
    end
  end

  def self.valid_survey_csv?(sheet)
    header = sheet.row(1)

    raise "Malformed CSV: incorrect length" unless (header.count.to_i == 15)
    raise "Malformed CSV: timestamp" unless (header[0].try(:downcase) == 'timestamp')
    raise "Malformed CSV: email address" unless (header[1].try(:downcase) == 'email address')
    raise "Malformed CSV: name" unless (header[2].try(:downcase) == 'name')
    raise "Malformed CSV: party" unless (header[3].try(:downcase) == 'party')
    raise "Malformed CSV: area" unless (header[4].try(:downcase) == 'area')

    true
  end
end
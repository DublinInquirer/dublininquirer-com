class AddAutolinkToTag < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :autolink, :boolean, default: false
    add_index :tags, :autolink, unique: false

    ElectionSurvey.all.each do |survey|
      survey.candidate_objects.each do |candidate|
        t = Tag.find_or_initialize_by(slug: candidate.slug)
        t.name = candidate.name
        t.displayable = t.persisted? ? t.displayable : false
        t.autolink = true
        t.save!
      end

      survey.area_objects.each do |area|
        t = Tag.find_or_initialize_by(slug: area.slug)
        t.name = area.name
        t.displayable = t.persisted? ? t.displayable : false
        t.autolink = true
        t.save!
      end

      survey.party_objects.each do |party|
        t = Tag.find_or_initialize_by(slug: party.slug)
        t.name = party.name
        t.displayable = t.persisted? ? t.displayable : false
        t.autolink = true
        t.save!
      end
    end
  end
end
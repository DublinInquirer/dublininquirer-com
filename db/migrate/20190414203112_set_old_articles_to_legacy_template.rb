class SetOldArticlesToLegacyTemplate < ActiveRecord::Migration[5.2]
  def change
    Article.where('created_at < ?', Date.new(2018,9,1)).where(template: ['standard', '', nil]).find_each do |a|
      a.update! template: 'legacy'
    end
  end
end

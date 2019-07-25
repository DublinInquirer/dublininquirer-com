namespace :users do
  task delete_scheduled: :environment do
    User.where('deleted_at < ?', Time.now).each { |u| u.delete_completely! }
  end
end

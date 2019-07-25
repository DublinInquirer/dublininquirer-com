namespace :users do
  task delete_scheduled: :environment do
    User.where('deleted_at < ?', Time.now).each { |u| puts "deleting #{ u.email_address }"; u.delete_completely! }
  end
end

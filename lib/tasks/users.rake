namespace :users do
  task delete_scheduled: :environment do
    User.where('deleted_at < ?', Time.now).each { |u| u.delete_completely! }
  end
  
  task delete_old_visitors: :environment do
    Visitor.where('updated_at < ?', 3.months.ago).where(user_id: nil).destroy_all
  end

  task mark_as_lapsed: :environment do
    Subscription.mark_as_lapsed!
  end  
end

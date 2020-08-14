every 30.minutes do
  rake "users:delete_scheduled"
end

every 1.day do
  rake "users:delete_old_visitors"
end

every 1.hours do
  rake "users:mark_as_lapsed"
end

every 30.minutes do
  rake "users:cancel_missing_subs"
end
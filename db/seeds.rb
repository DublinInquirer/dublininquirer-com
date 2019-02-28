if Rails.env.development?
  User.create!(email_address: 'admin@localhost', password: 'password123', role: 'superadmin')
end
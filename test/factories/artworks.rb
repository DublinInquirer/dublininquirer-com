FactoryBot.define do
  factory :artwork do
    image { Rack::Test::UploadedFile.new(Rails.root.join(*%w[test fixtures files example.jpg]), 'image/jpeg') }
  end
end
# 
FactoryBot.define do

  factory :post do
    body Faker::Lorem.paragraph(2, false, 4)
    attachment Faker::Name.last_name
    location [Faker::Address.latitude, Faker::Address.longitude]
    created_at Faker::Date.between(5.months.ago, 3.weeks.ago)
    updated_at Faker::Date.between(5.months.ago, 3.weeks.ago)
  end
  
end
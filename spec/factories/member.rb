# 
FactoryBot.define do
  factory :member, class: Member do
    name Faker::Name.name
    email Faker::Internet.email
    password "password"
    confirmed_at Date.new
  end
end
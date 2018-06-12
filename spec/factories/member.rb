# 
FactoryBot.define do

  factory :member do
    name { Faker::Name.first_name }
    surname { Faker::Name.last_name }
    email { Faker::Internet.email }
    password "password"
    confirmed_at Date.new
  end
  
end
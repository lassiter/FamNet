FactoryBot.define do
  factory :member do
    first_name    Faker::Name.first_name
    last_name     Faker::Name.last_name
    gender        [0,1,2].sample
    bio           Faker::Hipster.paragraphs(1)
    email         { "#{first_name}.#{last_name}@example.com".downcase }
    password      {"password"}
  end
end
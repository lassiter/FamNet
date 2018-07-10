FactoryBot.define do
  factory :event do
    title { "Title of Event" }
    description { Faker::Lorem.paragraph(2, false, 4) }
    attachment { Faker::Name.last_name }
    event_start { Faker::Time.forward(2, :morning) }
    event_end { Faker::Time.forward(2, :afternoon) }
    event_allday { [true,false].sample }
    location { [Faker::Address.latitude, Faker::Address.longitude] }
    potluck { [true,false].sample }
    locked { false }
    family_id { 1 }
    member_id { 1 }
    created_at { Faker::Date.between(2.years.ago, 3.weeks.ago) }
    updated_at { Faker::Date.between(2.years.ago, 3.weeks.ago) }
  end
end

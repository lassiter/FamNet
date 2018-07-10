FactoryBot.define do
  factory :recipe do
    title { Faker::Food.dish }
    description { Faker::Lorem.paragraph(2, false, 4)  }
    steps { "Use #{Faker::Food.measurement} of #{Faker::Food.ingredient}" }
    attachment { "attachment" }
    ingredients_list { Faker::Food.ingredient }
    tags_list { "tag" }
    # member_id entered
  end
end

FactoryBot.define do
  factory :event_rsvp do
    
    member_id { @party.slice!(0) }
    party_companions { @party }
    party_size { @party.size }
    # event_id {  } gets passed

    rsvp { 0 }
    rsvp_note { Faker::Lorem.paragraph(2, false, 1) }
    created_at { created_at = Faker::Date.between(5.days.ago, 3.weeks.ago) }
    updated_at { created_at }

    factory :event_rsvp_with_food do
      bringing_food { true }
      recipe_id { FactoryBot.create(:recipe, member_id: Member.last.id).id }
      serving { rand(3..15) }
    end

  end


end

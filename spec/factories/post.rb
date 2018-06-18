# 
FactoryBot.define do
require 'pry'
  factory :post do
    trait :with_comments do
      transient do
        comment_count 3
      end
    end
    before(:create) do
    
      family_member = create(:family_member)
    
    end

    body { Faker::Lorem.paragraph(2, false, 4) }
    attachment { Faker::Name.last_name }
    location { [Faker::Address.latitude, Faker::Address.longitude] }
    created_at { Faker::Date.between(5.months.ago, 3.weeks.ago) }
    updated_at { Faker::Date.between(5.months.ago, 3.weeks.ago) }
    member_id { FamilyMember.last.member_id }
    family_id { FamilyMember.last.family_id }



      after(:create) do |post, options|
        binding.pry
        FactoryBot.create_list(:comment, options.comment_count, member_id: Member.last.id)
      end
    end

    trait :with_comments_and_replies do
      transient do
        comment_count 3
      end

      after(:create) do |post, options|
        comment = FactoryBot.create_list(:comment, options.comment_count, member_id: Member.last.id)
        rand(1..3).times do
          FactoryBot.create(:comment_replies, comment_id: comment.id, member_id: FactoryBot.create(:member).id)
        end
      end
    end
 
end

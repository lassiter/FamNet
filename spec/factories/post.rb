# 
FactoryBot.define do
require 'pry'
  factory :post do

    body { Faker::Lorem.paragraph(2, false, 4) }
    attachment { Faker::Name.last_name }
    location { [Faker::Address.latitude, Faker::Address.longitude] }
    created_at { Faker::Date.between(5.months.ago, 3.weeks.ago) }
    updated_at { Faker::Date.between(5.months.ago, 3.weeks.ago) }
    family_id { family = FactoryBot.create(:family) }
    member_id { FactoryBot.create(:family_member, family_id: family.id).member_id }

    factory :post_with_children do
      after :create do |post|
        member_id = FactoryBot.create(:family_member, family_id: post.family_id).member.id
        FactoryBot.create_list(:comment, 3, commentable_id: post.id, commentable_type: "Post", member_id: member_id )

        post.comments.each do |comment|
          FactoryBot.create_list(:comment_reply, 3, comment_id: comment.id, member_id: FactoryBot.create(:family_member, family_id: comment.member.family_ids.first).member )
        end
      end
    end
  end
end

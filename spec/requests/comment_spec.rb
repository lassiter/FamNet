require 'rails_helper'
RSpec.describe "Comment API", type: :request do


  context ':: CRUD for Members on Comment ::' do

    it 'creates a Comment' do


    end
    it 'delete a Comment' do

    end

    it 'can render all of the Comments within a family' do

    end
  end
  context ':: Pundit ::' do
    before do
      family_member = create(:family_member)
      FactoryBot.create(:post, member_id: family_member.member_id, family_id: family_member.family_id, comment_count: 3)
    end
    it 'family members can see the comment' do

    end

    it 'non-family members can not see the comment' do

    end
  end
end
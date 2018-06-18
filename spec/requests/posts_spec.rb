require 'rails_helper'
RSpec.describe "Post API", type: :request do
  let(:family) { FactoryBot.create(:family) }
  let(:family_member) { FactoryBot.create(:family_member, family_id: create(:family).id) }
  let(:stringifed_family_member_name) { FactoryBot.create(:family_member, family_id: family.id) { [self.member.name, self.member.surname].join(" ") } }
  let(:create_post) { FactoryBot.create(:post, member_id: family_member.member_id, family_id: family_member.family_id) }

  context ':: CRUD for Members ::' do
    before do
      @family_member { create(:family_member) }
      3.times { create(:post) }
      5.times { create(:post, member_id: @family_member.member_id, family_id: @family_member.family_id) }
    end
    it 'can get Post Index' do
      
    end
    it 'can show a Post' do
      
    end
    it 'creates a Post' do
      new_post = FactoryBot.attributes_for(:post)
      member = Member.where(member_id: new_post[:member_id])
      sign_in member
      
      post '/v1/posts', params: new_post
      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)

      expect(json["family_id"]).to eql(new_post[:post][:family_id])
      expect(json["member_id"]).to eql(new_post[:post][:member_id])
      expect(json["body"]).to eql(new_post[:post][:body])
      expect(json["location"]).to eql(new_post[:post]["location"])

      expect(json["id"]).to exist

    end
    it 'update a Post' do
      
    end
    it 'delete a Post' do
      member = family_member.member_id
      sign_in member
      post = create(:post, member_id: member, family_id: member.family_ids.first)
      delete "/v1/posts/#{post.id}"
      expect(post).not_to exist
    end

    it 'can render all of the Posts within a family' do
      sign_in family_member.member_id
      get '/v1/posts'

      json = JSON.parse(response.body)
      json_first_post = json.first
      total_family_posts = Post.where(family_id: JSON.parse(json)["family_id"]).count

      expect(response).to have_http_status(:ok)
      expect(json.count).to eql(total_family_posts)

      expect(json_first_post["family_id"]).to eql(family_member.family_id)

    end
  end
  context ':: Pundit ::' do
    before(:each) do
      @family_member = FactoryBot.create(:family_member, family_id: family)
      @post = FactoryBot.create(:create_post, member_id: @family_member.member.id, family_id: family.id)
    end
    it 'family members can see the post' do
      second_family_member = FactoryBot.create(:family_member, family_id: @post.family_id)
      sign_in second_family_member

      get "/v1/posts/#{@post.id}"
      expect(response).to have_http_status(200)
    end

    it 'non-family members can not see the post' do
      non_family_member = FactoryBot.create(:family_member, family_id: family).member
      sign_in non_family_member

      get "/v1/posts/#{@post.id}"
      expect(response).to have_http_status(403)
    end
  end
end

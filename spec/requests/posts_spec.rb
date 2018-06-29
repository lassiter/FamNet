require 'rails_helper'
RSpec.describe "Post API", type: :request do
  before do
    @family = FactoryBot.create(:family)
    family_member = FactoryBot.create(:family_member, family_id: @family.id, authorized_at: DateTime.now)
    @member = family_member.member
    @member_family_id = family_member.family_id
  end
  describe ':: Members / Same Family ::' do
    before do
      login_auth(@member)
    end
    context "GET /posts Posts#index" do
      before do
        5.times { FactoryBot.create(:post, family_id: @member_family_id, member_id: FactoryBot.create(:family_member, family_id: @member_family_id, ).member_id ) }
        @comparable = Post.where(family_id: @member.families.ids) # todo: replace with pundit
      end
      before(:each) do
        @auth_headers = @member.create_new_auth_token
      end
      it "returns 200 status" do
        get '/v1/posts', :headers => @auth_headers
        expect(response).to have_http_status(200)
      end
      it 'and can get all of the records available to the Member\'s policy via index' do
        get '/v1/posts', :headers => @auth_headers

        json = JSON.parse(response.body) 
        expected = @comparable.first
        actual = json["data"].first
        expect(actual["id"].to_i).to eq(expected.id)
        expect(json["data"].count).to eq(@comparable.count)
        expect(response).to have_http_status(200)
      end
      it 'and getting the index returns the count and type of reactions for each record' do
        get '/v1/posts', :headers => @auth_headers
        json = JSON.parse(response.body)
        expected = @comparable.first.reactions
        actual = json["data"].first["relationships"]["reactions"]["data"]
        expect(actual).to eq(expected)
      end
      it 'and getting the index returns the comment_id each record' do
        get '/v1/posts', :headers => @auth_headers
        json = JSON.parse(response.body)
        expected = @comparable.first.comments
        actual = json["data"].first["relationships"]["comments"]
        expect(actual).to include("links")
        expect(actual["data"]).to eq(expected)
      end
      it 'shows links to relevant resources' do
        get '/v1/posts', :headers => @auth_headers
        
        json = JSON.parse(response.body)
        actual = json["data"].first["relationships"]
        expect(actual).to include("reactions")
        expect(actual).to include("comments")
        expect(actual).to include("member")
      end
    end
    context "GET /posts/:id Posts#show" do
      before do
        @comparable = FactoryBot.create(:post_with_children, family_id: @member_family_id, member_id: FactoryBot.create(:family_member, family_id: @member_family_id ).member_id )
      end
      before(:each) do
        @auth_headers = @member.create_new_auth_token
      end
      it "shows 200 status and matches comparable" do
        get "/v1/posts/#{@comparable.id}", :headers => @auth_headers

        json = JSON.parse(response.body)
        actual = json["data"]["attributes"]


        expect(response).to have_http_status(200)
        expect(json["data"]["id"].to_i).to eq(@comparable.id)
        expect(actual["body"]).to eq(@comparable.body)
        expect(actual["edit"]).to eq(@comparable.edit)
        expect(actual["location"]).to eq(@comparable.location)
        expect(actual["attachment"]).to eq(@comparable.attachment)
        expect(actual["locked"]).to eq(@comparable.locked)
        expect(actual["family_id"]).to eq(@comparable.family_id)
        expect(actual["member_id"]).to eq(@comparable.member_id)
      end
      it 'and it shows the requested post\'s Comments with CommentReplies' do
        get "/v1/posts/#{@comparable.id}", :headers => @auth_headers
        binding.pry
        json = JSON.parse(response.body)
        actual = json["data"]["relationships"]["comments"]["data"] # array of comments

        actual_comments = actual.first # first json comment
        expected_comments = @comparable.comments.first #first active record comment
        binding.pry
        actual_comment_replies = actual_comments.comment_replies # array of comment replies from first json comment
        expected_comment_replies = expected_comments.comment_replies # array of comment replies from first active record comment


        expect(actual.count).to eq(@comparable.comments.count)

        expect(actual_comments).to eq(expected_comments)
        expect(actual_comments["id"]).to eq(expected_comments.id)
        expect(actual_comments["body"]).to eq(expected_comments.body)
        expect(actual_comments["edit"]).to eq(expected_comments.edit)
        expect(actual_comments["attachment"]).to eq(expected_comments.attachment)
        expect(actual_comments["commentable_type"]).to eq(expected_comments.commentable_type)
        expect(actual_comments["commentable_id"]).to eq(expected_comments.commentable_id)
        expect(actual_comments["member_id"]).to eq(expected_comments.member_id)

        expect(actual_comment_replies).to eq(@expected_comment_replies)
        expect(actual_comment_replies["id"]).to eq(@expected_comment_replies.id)
        expect(actual_comment_replies["body"]).to eq(@expected_comment_replies.body)
        expect(actual_comment_replies["edit"]).to eq(@expected_comment_replies.edit)
        expect(actual_comment_replies["comment_id"]).to eq(@expected_comment_replies.comment_id)
        expect(actual_comment_replies["member_id"]).to eq(@expected_comment_replies.member_id)

      end
      it 'and it shows the requested post\'s Reactions' do
        get "/v1/posts/#{@comparable.id}", :headers => @auth_headers
        json = JSON.parse(response.body)
        actual = json["data"]["relationships"]["reaction"]["data"]
        expected = @comparable.reactions
        expect(actual.count).to eq(expected.count)

        actual_reaction = actual.first
        expected_reaction = expected.first

        expect(actual_reaction["id"]).to eq(expected_reaction.id)
        expect(actual_reaction["emotive"]).to eq(expected_reaction.emotive)
        expect(actual_reaction["interaction_type"]).to eq(expected_reaction.interaction_type)
        expect(actual_reaction["interaction_type"]).to eq(expected_reaction.interaction_type)
        expect(actual_reaction["member_id"]).to eq(expected_reaction.member_id)      
      end
      it 'shows the relationships and links to them in the json package' do
        get "/v1/posts/#{@comparable.id}", :headers => @auth_headers
        json = JSON.parse(response.body)
        actual_post_links = json["data"]["links"]
        actual_reaction_links = json["data"]["relationships"]["reaction"]["data"]["links"]
        actual_comment_links = json["data"]["relationships"]["comment"]["data"]["links"]
        actual_comment_reply_links = json["data"]["relationships"]["comment"]["data"]["relationships"]["comment_reply"]["data"]["links"]

        expected_resource = @comparable
        expected_reaction = @comparable.reactions.first
        expected_comment = @comparable.comments.first
        expected_comment_reply = expected_comment.comment_replies

        expected_post_links = {links: { self: Rails.application.routes.url_helpers.api_v1_post_path(expected_resource.id), next: Rails.application.routes.url_helpers.api_v1_post_path( get_next_family_resource(expected_resource.id, expected_resource.class.to_s) ), prev: Rails.application.routes.url_helpers.api_v1_post_path( get_prev_family_resource(expected_resource.id, expected_resource.class.to_s) ) } }
        expected_reaction_links = {links: { self: Rails.application.routes.url_helpers.api_v1_post_reactions_path(expected_reaction.id), create: Rails.application.routes.url_helpers.api_v1_reaction_path(expected_reaction.id), destroy: Rails.application.routes.url_helpers.api_v1_reaction_path(expected_reaction.id) } }
        expected_comment_links = {links: { self: Rails.application.routes.url_helpers.api_v1_post_comments_path(expected_comment.id), next: Rails.application.routes.url_helpers.api_v1_post_comments_path( get_next_family_resource(expected_comment.id, expected_comment.class.to_s) ), prev: Rails.application.routes.url_helpers.api_v1_post_comments_path( get_prev_family_resource(expected_comment.id, expected_comment.class.to_s) ) } }
        expected_comment_reply_links = {links: { self: Rails.application.routes.url_helpers.api_v1_post_comment_comment_reply_path(expected_comment_reply), next: Rails.application.routes.url_helpers.api_v1_post_comment_comment_reply_path( get_next_family_resource(expected_comment_reply.id, expected_comment_reply.class.to_s) ), prev: Rails.application.routes.url_helpers.api_v1_post_comment_comment_reply_path( get_prev_family_resource(expected_comment_reply.id, expected_comment_reply.class.to_s) ) } }

        expect(actual_post_links).to eq(expected_resource_links)
        expect(actual_reaction_links).to eq(expected_reaction_links)
        expect(actual_comment_links).to eq(expected_comment_links)
        expect(actual_comment_reply_links).to eq(expected_comment_reply_links)

      end
      it 'shows links to relevant resources' do
        get "/v1/posts/#{@comparable.id}", :headers => @auth_headers
        json = JSON.parse(response.body)
        actual = json["data"]["relationships"]
        expect(actual).to include("reactions")
        expect(actual).to include("comments")
        expect(actual).to include("member")
      end
    end
    context "POST /posts Posts#create" do
      before do
       @comparable = FactoryBot.build(:post, family_id: @member_family_id, member_id: @member.id )
       @create_request_params = {
          "post": {
            "body": @comparable.body,
            "location": @comparable.location,
            "family_id": @comparable.family_id,
            "member_id": @comparable.member_id
          }
        }
      end
      before(:each) do
        @auth_headers = @member.create_new_auth_token
      end
      it "200 status" do
        post '/v1/posts', :params => @create_request_params, :headers => @auth_headers
        expect(response).to have_http_status(200)
      end
      it 'and it returns the json for the newly created post' do
        post '/v1/posts', :params => @create_request_params, :headers => @auth_headers
        
        json = JSON.parse(response.body)
        actual = json["data"]["attributes"]


        expect(response).to have_http_status(200)
        expect(actual["body"]).to eq(@comparable.body)
        expect(actual["location"]).to eq(@comparable.location) # currently dec needs to be float
        expect(actual["family-id"]).to eq(@comparable.family_id)
        expect(actual["member-id"]).to eq(@comparable.member_id)
      end
      it 'shows the relationships and links to them in the json package' do
        post '/v1/posts', :params => @create_request_params, :headers => @auth_headers
        json = JSON.parse(response.body)
        actual = json["data"]["relationships"]
        expect(actual).to include("reactions")
        expect(actual).to include("comments")
        expect(actual).to include("member")
      end
    end
    context "PUT - PATCH /posts/:id Posts#update" do
      before(:each) do
        @auth_headers = @member.create_new_auth_token
        @comparable = FactoryBot.create(:post, family_id: @member_family_id, member_id: @member.id )
        update_put = FactoryBot.build(:post, family_id: @member_family_id, member_id: @member.id )
        update_patch = FactoryBot.build(:post, family_id: @member_family_id, member_id: @member.id )
        @update_put_request_params = {
          "id": @comparable.id,
          "post": {
            "id": @comparable.id,
            "attributes": {
              "family_id": @comparable.family_id,
              "member_id": @comparable.member_id,
              "body": update_put.body,
              "location": update_put.location,
              "edit": update_put.edit,
              "attachment": update_put.attachment,
              "locked": update_put.locked,
              "created_at": "2018-06-16T22:40:39.363Z",
              "updated_at": update_put.updated_at
            }
          }
        }
        @update_patch_request_params = {
          "id": @comparable.id,
          "post": {
            "id": @comparable.id,
            "attributes": {
              "body": update_patch.body
            }
          }
        }
      end
      it "#put 200 status and matches the json for the putted post" do
        put "/v1/posts/#{@comparable.id}", :params => @update_put_request_params, :headers => @auth_headers
        expected = @update_put_request_params[:post][:attributes]
        
        json = JSON.parse(response.body)
        actual = json["data"]["attributes"]
        
        expect(response).to have_http_status(200)
        expect(actual["body"]).to eq(expected[:body])
        expect(actual["location"]).to eq(expected[:location])
        expect(actual["family-id"]).to eq(expected[:family_id])
        expect(actual["member-id"]).to eq(expected[:member_id])
        expect(actual["attachment"]).to eq(expected[:attachment])
        expect(actual["edit"]).to eq(expected[:edit])
        expect(actual["created-at"].to_datetime).to_not eq(expected[:created_at])
        expect(actual["updated-at"].to_datetime).to eq(expected[:updated_at])
      end
      it "#patch 200 status and can replace a single attribute and it returns the json for the patched post" do
        patch "/v1/posts/#{@comparable.id}", :params => @update_patch_request_params, :headers => @auth_headers
        expected = @update_patch_request_params[:post][:attributes]
        
        json = JSON.parse(response.body)
        actual = json["data"]
        expect(response).to have_http_status(200)
        expect(actual["id"].to_i).to eq(@comparable.id)
        expect(actual["attributes"]["body"]).to eq(expected[:body])
        expect(actual["attributes"]["edit"]).to eq(@comparable.edit)
        expect(actual["attributes"]["location"]).to eq(@comparable.location)
        expect(actual["attributes"]["attachment"]).to eq(@comparable.attachment)
        expect(actual["attributes"]["locked"]).to eq(@comparable.locked)
        expect(actual["attributes"]["family-id"]).to eq(@comparable.family_id)
        expect(actual["attributes"]["member-id"]).to eq(@comparable.member_id)
      end
      it '#patch shows the relationships and links to them in the json package' do
        patch "/v1/posts/#{@comparable.id}", :params => @update_patch_request_params, :headers => @auth_headers
        json = JSON.parse(response.body)
        actual = json["data"]["relationships"]
        expect(actual).to include("reactions")
        expect(actual).to include("comments")
        expect(actual).to include("member")
      end
      it '#put shows the relationships and links to them in the json package' do
        patch "/v1/posts/#{@comparable.id}", :params => @update_put_request_params, :headers => @auth_headers
        json = JSON.parse(response.body)
        actual = json["data"]["relationships"]
        expect(actual).to include("reactions")
        expect(actual).to include("comments")
        expect(actual).to include("member")
      end
    end
    context "DELETE /posts/:id Posts#destroy" do
      before(:each) do
        @auth_headers = @member.create_new_auth_token
      end
      it "can sucessfully delete a post" do
        @comparable = FactoryBot.create(:post, family_id: @member_family_id, member_id: @member.id )
        @delete_request_params = {:id => @comparable.id }

        delete "/v1/posts/#{@comparable.id}", :params => @delete_request_params, :headers => @auth_headers
        expect(response).to have_http_status(204)
      end
      it 'returns 404 for missing content' do
        @comparable = FactoryBot.create(:post, family_id: @member_family_id, member_id: @member.id )
        Post.find(@comparable.id).destroy
        delete "/v1/posts/#{@comparable.id}", :params => @delete_request_params, :headers => @auth_headers
        json = JSON.parse(response.body) 
        expect(json).to eq({})
        expect(response).to have_http_status(404)
      end
    end
    context "Unauthorize Inside Family ::" do
      before do
        @member = FactoryBot.create(:family_member, family_id: @family.id, authorized_at: DateTime.now).member
        @second_member = FactoryBot.create(:family_member, family_id: @family.id, authorized_at: DateTime.now).member
        login_auth(@member)
      end
      context "GET /posts Posts#update :: Member 2 => Member 1 ::" do
        before(:each) do
          @auth_headers = @member.create_new_auth_token
          @comparable = FactoryBot.create(:post, family_id: @family.id, member_id: @second_member.id )
          @updates = FactoryBot.build(:post, id: @comparable.id, family_id: @family.id, member_id: @member.id, locked: true )
        end
        it "unable to #put update on another family member's post" do
          unauthorized_update_put_request_params = {
            "id": @updates[:id],
            "post": {
              "id": @updates[:id],
              "attributes": {
                "family_id": @updates[:family_id],
                "member_id": @updates[:member_id],
                "body": @updates[:body],
                "location": @updates[:location],
                "edit": @updates[:edit],
                "attachment": @updates[:attachment],
                "locked": @updates[:locked],
                "updated_at": @updates[:updated_at]
              }
            }
          }

          put "/v1/posts/#{@comparable.id}", :params => unauthorized_update_put_request_params, :headers => @auth_headers
          expect(response).to have_http_status(403)
        end
        it "unable to #patch update on another family member's post" do
          unauthorized_patch_of_post_params = {
            "id": @updates[:id],
            "post": {
              "body": @updates[:body]
            }
          }

          patch "/v1/posts/#{@comparable.id}", :params => unauthorized_patch_of_post_params, :headers => @auth_headers
          expect(response).to have_http_status(403)
        end
        it "unable to #patch update on a protected field" do
          update_patch_request_unpermitted_params = {
            "id": @updates[:id],
            "post": {
              "id": @updates[:id],
              "family_id": @updates[:family_id],
              "member_id": @updates[:member_id],
              "edit": @updates[:edit],
              "locked": @updates[:locked],
              "created_at": @updates[:created_at]
            }
          }
          patch "/v1/posts/#{@comparable.id}", :params => update_patch_request_unpermitted_params, :headers => @auth_headers
          expect(response).to have_http_status(403)
        end
        it "unable to #put update on a protected field" do
          update_put_request_unpermitted_params = {
            "id": @updates[:id],
            "post": {
              "id": @updates[:id],
              "family_id": @updates[:family_id],
              "member_id": @updates[:member_id],
              "edit": @updates[:edit],
              "locked": @updates[:locked],
              "created_at": @updates[:created_at]
            }
          }
          put "/v1/posts/#{@comparable.id}", :params => update_put_request_unpermitted_params, :headers => @auth_headers
          expect(response).to have_http_status(403)
        end
      end
      context "DELETE /posts Posts#delete :: Member 2 => Member 1" do
      before(:each) do
        @auth_headers = @member.create_new_auth_token
      end
        it "unable to delete on another family member's post" do
          @comparable = FactoryBot.create(:post, family_id: @member_family_id, member_id: FactoryBot.create(:family_member, family_id: @member_family_id ).member_id )
          delete_request_params = {:id => @comparable.id }
          delete "/v1/posts/#{@comparable.id}", :params => delete_request_params, :headers => @auth_headers
          expect(response).to have_http_status(403)
        end
      end
    end
  end # Members / Same Family Describe
  
  describe ':: Members / Same Family - Admin Role ::' do
    before do
      @family = FactoryBot.create(:family)
      family_member = FactoryBot.create(:family_member, family_id: @family.id)
      @admin_member = family_member.member
      @admin_member.update_attribute(:user_role, "admin")
      @member_family_id = @family.id
      @member = FactoryBot.create(:family_member, family_id: @family.id).member
    end
    before(:each) do
      @auth_headers = @admin_member.create_new_auth_token
      @comparable = FactoryBot.create(:post, family_id: @member_family_id, member_id: @member.id )
      update_put = FactoryBot.build(:post, family_id: @member_family_id, member_id: @admin_member.id )
      update_patch = FactoryBot.build(:post, family_id: @member_family_id, member_id: @admin_member.id )
      @update_put_request_params = {
        "id": @comparable.id,
        "post": {
          "id": @comparable.id,
          "family_id": @comparable.family_id,
          "member_id": @comparable.member_id,
          "body": update_put.body,
          "location": update_put.location,
          "edit": update_put.edit,
          "attachment": update_put.attachment,
          "locked": update_put.locked,
          "created_at": "2018-06-16T22:40:39.363Z",
          "updated_at": update_put.updated_at
        }
      }
      @update_patch_request_params = {
        "id": @comparable.id,
        "post": {
          "body": update_patch.body
        }
      }
    end
    context "GET /posts Posts#update" do
      it "able to #put update on another family member's post" do
        get '/v1/posts'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it "able to #patch update on another family member's post" do
        get '/v1/posts'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
    end
    context "GET /posts Posts#destroy" do
      it "able to delete on another family member's post" do
        get '/v1/posts'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
    end
  end # Members / Same Family - Admin Role Describe
  
  describe ':: Members / Unauthorized to Family ::' do
    before do
      @family = FactoryBot.create(:family)
      family_member = FactoryBot.create(:family_member, family_id: @family.id)
      @member = family_member.member

      unauthorized_member = FactoryBot.create(:family_member)
      @unauthorized_member = unauthorized_member.member
      @unauthorized_member_family_id = unauthorized_member.family_id
      login_auth(@unauthorized_member)
    end
    context "GET /posts Posts#index" do
      before do
        FactoryBot.create_list(:post_with_children, 5, family_id: @family.id)
        @comparable = Post.where(family_id: @family.id) # todo: replace with pundit
      end
      before(:each) do
        @auth_headers = @member.create_new_auth_token
      end
      it "200 and returns 0 posts" do
        get '/v1/posts', :headers => @auth_headers
        json = JSON.parse(response.body) 
        expected = @comparable.first
        actual = json["data"].first
        expect(actual["id"]).to eq(expected.id)
        expect(json.count).to eq(0)
        expect(response).to have_http_status(200)
      end
      it 'shows the relationships and links to them in the json package' do
        get '/v1/posts', :headers => @auth_headers
        json = JSON.parse(response.body)
        actual = json["relationships"]
        expect(actual["reactions"]).to eq("reactions")
        expect(actual["comments"]).to eq("comments")
      end
      it 'shows links to relevant resources' do
        get '/v1/posts', :headers => @auth_headers
        
        json = JSON.parse(response.body)
        actual = json["relationships"]
        expected = {"reactions" => Rails.application.routes.url_helpers.api_v1_reactions_path, "comments" => Rails.application.routes.url_helpers.api_v1_post_comments_path(":post_id"), "comment" => Rails.application.routes.url_helpers.api_v1_post_comment_path(":post_id", ":comment_id")}
        expect(actual["reactions"]).to eq("reactions")
        expect(actual["comments"]).to eq("comments")
        expect(actual["comment"]).to eq("comment")
      end
    end
    context "GET /posts Posts#show" do
      before do
        @comparable = FactoryBot.create(:post_with_children, family_id: @family.id) # todo: replace with pundit
      end
      before(:each) do
        @auth_headers = @unauthorized_member.create_new_auth_token
      end
      it "returns 403 status code on unauthorized access" do
        get "/v1/posts/#{@comparable.id}", :headers => @auth_headers
        expect(response).to have_http_status(403)
      end
    end
    context "GET /posts Posts#create" do
      before do
        @comparable = FactoryBot.build(:post, family_id: @family.id) # todo: replace with pundit
      end
      before(:each) do
        @auth_headers = @unauthorized_member.create_new_auth_token
      end
      it "works! (now write some real specs)" do
        post "/v1/posts", :params => @comparable, :headers => @auth_headers
        expect(response).to have_http_status(403)
      end
    end
    context "GET /posts Posts#update" do
      it "#put works! (now write some real specs)" do
        get '/v1/posts'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it 'and it returns the json for the putted post' do
        get '/v1/posts'
        expect(response).to have_http_status(403)
      end
      it "#patch can replace a single attribute" do
        get '/v1/posts'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it 'and it returns the json for the patched post' do
        get '/v1/posts'
        expect(response).to have_http_status(403)
      end
      it 'shows the relationships and links to them in the json package' do
        get '/v1/posts'
        expect(response).to have_http_status(403)
      end
    end
    context "GET /posts Posts#destroy" do
      it "works! (now write some real specs)" do
        get '/v1/posts'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it 'can sucessfully delete a post' do
        expect(response).to have_http_status(403)
      end
      it 'returns 404 for missing content' do
        expect(response).to have_http_status(403)
      end
    end
  end # Members / Unauthorized to Family Describe
  describe ':: Unknown User ::' do
    before do
      @member = nil
    end
    context "GET /posts Posts#index" do
      before do
        FactoryBot.create_list(:post_with_children, 2, family_id: @family.id)
        @comparable = Post.where(family_id: @family.id) # todo: replace with pundit
      end
      it "returns a 401 error saying they are not authenticated" do
        get "/v1/posts", :params => @comparable
        expect(response).to have_http_status(401)
      end
    end
    context "GET /posts Posts#show" do
      before do
        @comparable = FactoryBot.create(:post_with_children, 1, family_id: @family.id)
      end
      it "returns a 401 error saying they are not authenticated" do
        get "/v1/posts/#{@comparable.id}"
        expect(response).to have_http_status(401)
      end
    end
    context "GET /posts Posts#create" do
      before do
        @comparable = FactoryBot.build(:post, family_id: @family.id)
      end
      it "returns a 401 error saying they are not authenticated" do
        post "/v1/posts", :params => @comparable
        expect(response).to have_http_status(401)
      end
    end
    context "GET /posts Posts#update" do
      before do
        @comparable = FactoryBot.build(:post, family_id: @family.id)
      end
      it "#put returns a 401 error saying they are not authenticated" do
        put "/v1/posts/#{@comparable.id}", :params => @comparable
        expect(response).to have_http_status(401)
      end
      it "#patch returns a 401 error saying they are not authenticated" do
        patch "/v1/posts/#{@comparable.id}", :params => @comparable
        expect(response).to have_http_status(401)
      end
    end
    context "GET /posts Posts#destroy" do
      before do
        @comparable = FactoryBot.create(:post, family_id: @family.id)
      end
      it "returns a 401 error saying they are not authenticated" do
        delete "/v1/posts/#{@comparable.id}", :params => @comparable
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(401)
      end
    end
  end # Unknown User Describe


end

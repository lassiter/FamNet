require 'rails_helper'

RSpec.describe "Events & EventRsvps", type: :request do
  before do
    @family = FactoryBot.create(:family)
    family_member = FactoryBot.create(:family_member, family_id: @family.id, authorized_at: DateTime.now)
    @member = family_member.member
    @member_family_id = family_member.family_id
  end
  context ':: Events' do
    @comparable = FactoryBot.create_list(:event, 5, family_id: @family.id, member_id: @member.id)
    describe ':: Members / Same Family ::' do
      before do
        login_auth(@member)
      end
      context "GET /events Events#index" do
        before(:each) do
          @member.create_new_auth_token
        end
        
        it "200 status" do
          get '/v1/events', :headers => @auth_headers
          expect(response).to have_http_status(200)
        end
        it 'and can get all of the records available to the Member\'s policy via index' do
          get '/v1/events', :headers => @auth_headers
          json = JSON.parse(response.body) 
          expected = @comparable.first
          actual = json["data"].first
          expect(actual["id"].to_i).to eq(expected.id)
          expect(json["data"].count).to eq(@comparable.count)
          expect(response).to have_http_status(200)
        end
      end
      context "GET /events Events#show" do
        @comparable = @comparable.first
        it "200 status" do
          get "/v1/events/#{@comparable.id}", :headers => @auth_headers
          expect(response).to have_http_status(200)
        end
        it 'and it shows the event requested' do
          get "/v1/events/#{@comparable.id}", :headers => @auth_headers
          json = JSON.parse(response.body)
          actual = json["data"]["attributes"]


          expect(response).to have_http_status(200)
          expect(json["data"]["id"].to_i).to eq(@comparable.id)
          expect(actual["title"]).to eq(@comparable.title)
          expect(actual["description"]).to eq(@comparable.description)
          expect(actual["attachment"]).to eq(@comparable.attachment)
          expect(actual["locked"]).to eq(@comparable.locked)
          expect(actual["potluck"]).to eq(@comparable.potluck)
          expect(actual["family-id"]).to eq(@comparable.family_id)
          expect(actual["member-id"]).to eq(@comparable.member_id)

          expect(actual["event-allday"]).to eq(@comparable.event_allday)
          expect(actual["event-start"]).to eq(@comparable.event_start)
          expect(actual["event-end"]).to eq(@comparable.event_end)


          expect(actual["location"][0]).to be_within(0.000000000009).of(@comparable.location[0])
          expect(actual["location"][1]).to be_within(0.000000000009).of(@comparable.location[1])
        end
        it 'and it shows event\'s comments and reactions' do
          family_member = FactoryBot.create(:family_member, family_id: @family.id).member
          FactoryBot.create(:comment, commentable_type:"Event", commentable_id: @comparable.id, member_id: family_member)
          FactoryBot.create(:reaction, interaction_type:"Event", interaction_id: @comparable.id, member_id: family_member)
          
          get "/v1/events/#{@comparable.id}", :headers => @auth_headers
          json = JSON.parse(response.body)
          actual = json["data"]["relationships"] # array of comments

          actual_comments = actual["comments"]["data"].first # first json comment
          expected_comments = @comparable.comments.first #first active record comment

          expect(actual["comments"]["data"].count).to eq(@comparable.comments.count)

          expect(actual_comments["id"].to_i).to eq(expected_comments.id)
          expect(actual_comments["type"].downcase).to eq(expected_comments.class.to_s.downcase)

          actual_reactions = actual["reactions"]["data"].first # first json reaction
          expected_reactions = @comparable.reactions.first #first active record reaction

          expect(actual["reactions"]["data"].count).to eq(@comparable.reactions.count)

          expect(actual_reactions["id"].to_i).to eq(expected_reactions.id)
          expect(actual_reactions["type"].downcase).to eq(expected_reactions.class.to_s.downcase)
        end
        it 'shows the relationships and links' do
          get "/v1/events#{@comparable.id}", :headers => @auth_headers
          json = JSON.parse(response.body)
          
          actual_event_links = json["data"]["links"]
          actual_member_links = json["data"]["relationships"]["member"]["links"]
          actual_reaction_links = json["data"]["relationships"]["reactions"]["links"]
          actual_comment_links = json["data"]["relationships"]["comments"]["links"]

          expected_resource = @comparable
          expected_member = @comparable.member
          expected_reaction = @comparable.reactions.first
          expected_comment = @comparable.comments.first

          expect(json["data"]["id"].to_i).to eq(@comparable.id)
          expect(actual_event_links["self"]).to include("#{@comparable.id}")
          expect(actual_event_links["comments"]).to include("comments","#{@comparable.id}")
          expect(actual_event_links["member"]).to include("member","#{@comparable.member.id}")

          expect(actual_member_links["related"]).to include("member","#{@comparable.member.id}")

          expect(actual_reaction_links["related"]).to include("reactions","#{@comparable.id}")

          expect(actual_comment_links["related"]).to include("comments","#{@comparable.id}")
          

        end
      end
      context "GET /events Events#create" do
        before(:each) do
          event = FactoryBot.build(:event, family_id: @family.id, member_id: @member.id)
          @create_request_params = {
            "event": {
              "attributes": event.serializable_hash.except!("id", "created_at", "updated_at").to_json
            }
          }
          @auth_headers = @member.create_new_auth_token
        end
        it "200 status with correct type with id that is not nil" do
          post '/v1/events', :params => @create_request_params, :headers => @auth_headers
          json = JSON.parse(response.body)["data"]
          type = JSON.parse(response.body)["data"]["type"]
          expect(type.to_s).to eq("event")
          expect(json).to include("id")
          expect(json["id"]).to_not eq(nil)
          expect(response).to have_http_status(200)
        end
        it 'and it returns the json for the newly created post' do
          post '/v1/events', :params => @create_request_params, :headers => @auth_headers
          actual = JSON.parse(response.body)["data"]["attributes"]
          expected = @create_request_params["event"]["attributes"]
          expect(response).to have_http_status(200)

          expect(actual["title"]).to eq(expected["title"])
          expect(actual["description"]).to eq(expected["description"])
          expect(actual["attachment"]).to eq(expected["attachment"])
          expect(actual["event-start"]).to eq(expected["event_start"])
          expect(actual["event-end"]).to eq(expected["event_end"])
          expect(actual["event-allday"]).to eq(expected["event_allday"])

          expect(actual["potluck"]).to eq(expected["potluck"])
          expect(actual["locked"]).to eq(expected["locked"])

          expect(actual["family-id"]).to eq(expected["family_id"])
          expect(actual["member-id"]).to eq(expected["member_id"])

          expect(actual["location"][0]).to be_within(0.000000000009).of(expected["location"][0])
          expect(actual["location"][1]).to be_within(0.000000000009).of(expected["location"][1])
        end
        it 'shows the relationships and links to them in the json package' do
          post '/v1/events', :params => @create_request_params, :headers => @auth_headers
          actual = JSON.parse(response.body)["data"]["relationships"]
          expect(actual).to include("member")
        end
      end
      context "PUT - PATCH /events/:id Posts#update" do
        before(:each) do
          @auth_headers = @member.create_new_auth_token
          @comparable = FactoryBot.create(:event, family_id: @member_family_id, member_id: @member.id )
          update_put = FactoryBot.build(:event, family_id: @member_family_id, member_id: @member.id )
          update_patch = FactoryBot.build(:event, family_id: @member_family_id, member_id: @member.id )
          @update_put_request_params = {
            "id": @comparable.id,
            "event": {
              "id": @comparable.id,
              "attributes": update_put.serializable_hash.except!("id", "created_at", "updated_at").to_json
            }
          }
          @update_patch_request_params = {
            "id": @comparable.id,
            "event": {
              "id": @comparable.id,
              "attributes": {
                "title": update_patch.title
              }
            }
          }
        end
        it "#put 200 status and matches the json for the putted post" do
          put "/v1/events/#{@comparable.id}", :params => @update_put_request_params, :headers => @auth_headers
          expected = @update_put_request_params[:event][:attributes]
          actual = JSON.parse(response.body)["data"]["attributes"]
          
          expect(response).to have_http_status(200)
          expect(actual["title"]).to eq(expected["title"])
          expect(actual["description"]).to eq(expected["description"])
          expect(actual["attachment"]).to eq(expected["attachment"])
          expect(actual["event-start"]).to eq(expected["event_start"])
          expect(actual["event-end"]).to eq(expected["event_end"])
          expect(actual["event-allday"]).to eq(expected["event_allday"])

          expect(actual["potluck"]).to eq(expected["potluck"])
          expect(actual["locked"]).to eq(expected["locked"])

          expect(actual["family-id"]).to eq(expected["family_id"])
          expect(actual["member-id"]).to eq(expected["member_id"])

          expect(actual["location"][0]).to be_within(0.000000000009).of(expected["location"][0])
          expect(actual["location"][1]).to be_within(0.000000000009).of(expected["location"][1])
          
          expect(actual["created-at"].to_datetime).to_not eq(expected[:created_at])
          expect(actual["updated-at"].to_datetime).to_not eq(expected[:updated_at])
        end
        it "#patch 200 status and can replace a single attribute and it returns the json for the patched post" do
          patch "/v1/events/#{@comparable.id}", :params => @update_patch_request_params, :headers => @auth_headers
          expected = @update_patch_request_params[:event][:attributes]
          
          json = JSON.parse(response.body)
          actual = json["data"]
          expect(response).to have_http_status(200)
          expect(actual["id"].to_i).to eq(@comparable.id)
          expect(actual["attributes"]["title"]).to eq(expected[:title])
          expect(actual["attributes"]["description"]).to eq(@comparable.description)
          expect(actual["attributes"]["attachment"]).to eq(@comparable.attachment)
          expect(actual["attributes"]["locked"]).to eq(@comparable.locked)
          expect(actual["attributes"]["family-id"]).to eq(@comparable.family_id)
          expect(actual["attributes"]["member-id"]).to eq(@comparable.member_id)

          expect(actual["attributes"]["location"][0]).to be_within(0.000000000009).of(@comparable.location[0])
          expect(actual["attributes"]["location"][1]).to be_within(0.000000000009).of(@comparable.location[1])
        end
        it '#patch shows the relationships and links to them in the json package' do
          patch "/v1/events/#{@comparable.id}", :params => @update_patch_request_params, :headers => @auth_headers
          actual = JSON.parse(response.body)["data"]["relationships"]
          expect(actual).to include("member")
        end
        it '#put shows the relationships and links to them in the json package' do
          patch "/v1/events/#{@comparable.id}", :params => @update_put_request_params, :headers => @auth_headers
          actual = JSON.parse(response.body)["data"]["relationships"]
          expect(actual).to include("member")
        end
      end
      context "GET /events Events#destroy" do
        before(:each) do
          @auth_headers = @member.create_new_auth_token
        end
        it "can sucessfully delete a event" do
          @comparable = FactoryBot.create(:event, family_id: @member_family_id, member_id: @member.id )
          @delete_request_params = {:id => @comparable.id }

          delete "/v1/events/#{@comparable.id}", :params => @delete_request_params, :headers => @auth_headers
          expect(response).to have_http_status(204)
        end
        it 'returns 404 for missing content' do
          @comparable = FactoryBot.create(:event, family_id: @member_family_id, member_id: @member.id )
          Event.find(@comparable.id).destroy
          delete "/v1/events/#{@comparable.id}", :params => @delete_request_params, :headers => @auth_headers
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
            @comparable = FactoryBot.create(:event, family_id: @member_family_id, member_id: @second_member.id )
            @updates = FactoryBot.create(:event, family_id: @member_family_id, member_id: @member.id )
          end
          it "unable to #put update on another family member's post" do
            unauthorized_update_put_request_params = {
            "id": @updates.id,
              "event": {
                "id": @updates.id,
                "attributes": update_put.serializable_hash.except!("id", "created_at", "updated_at").to_json
              }
            }

            put "/v1/events/#{@comparable.id}", :params => unauthorized_update_put_request_params, :headers => @auth_headers
            expect(response).to have_http_status(403)
          end
          it "unable to #patch update on another family member's post" do
            unauthorized_patch_of_event_params = {
              "id": @comparable.id,
              "event": {
                "id": @comparable.id,
                "attributes": {
                  "title": @updates.title
                }
              }
            }

            patch "/v1/events/#{@comparable.id}", :params => unauthorized_patch_of_event_params, :headers => @auth_headers
            expect(response).to have_http_status(403)
          end
          it "unable to #patch update on a protected field" do
            update_patch_request_unpermitted_params = {
            "id": @updates.id,
              "event": {
                "id": @updates.id,
                "attributes": @updates.serializable_hash.except!("title", "description", "attachment", "event_start", "event_end", "event_allday", "location", "potluck", "family_id", "member_id").to_json
              }
            }
            patch "/v1/events/#{@comparable.id}", :params => update_patch_request_unpermitted_params, :headers => @auth_headers
            expect(response).to have_http_status(403)
          end
          it "unable to #put update on a protected field" do
            update_put_request_unpermitted_params = {
            "id": @updates.id,
              "event": {
                "id": @updates.id,
                "attributes": @updates.serializable_hash.except!("title", "description", "attachment", "event_start", "event_end", "event_allday", "location", "potluck", "family_id", "member_id").to_json
              }
            }
            put "/v1/events/#{@comparable.id}", :params => update_put_request_unpermitted_params, :headers => @auth_headers
            expect(response).to have_http_status(403)
          end
        end
        context "DELETE /events Posts#delete :: Member 2 => Member 1" do
          before(:each) do
            @auth_headers = @member.create_new_auth_token
          end
          it "unable to delete on another family member's post" do
            @comparable = FactoryBot.create(:event, family_id: @family.id, member_id: FactoryBot.create(:family_member, family_id: @family.id ).member_id )
            delete_request_params = {:id => @comparable.id }
            delete "/v1/events/#{@comparable.id}", :params => delete_request_params, :headers => @auth_headers
            expect(response).to have_http_status(403)
          end
        end
      end
    end # Members / Same Family Describe
    
    describe ':: Members / Same Family - Admin Role ::' do
      before do
        @second_member = FactoryBot.create(:family_member, family_id: @family.id, authorized_at: DateTime.now).member
        family_member = FactoryBot.create(:family_member, authorized_at: DateTime.now, user_role: "admin")
        @member = family_member.member
        login(@member)
      end
      context "GET /events Events#update" do
        before(:each) do
          @auth_headers = @member.create_new_auth_token
          @comparable = FactoryBot.create(:event, family_id: @family.id, member_id: @second_member.id )
          update = FactoryBot.build(:event, family_id: @member_family_id, member_id: @member.id )
          @update_put_request_params = {
            "id": @comparable.id,
            "event": {
              "id": @comparable.id,
              "attributes": update.serializable_hash.except!("id", "created_at", "updated_at").to_json
            }
          }
          @update_patch_request_params = {
            "id": @comparable.id,
            "event": {
              "id": @comparable.id,
              "attributes": {
                "title": update.title
              }
            }
          }
        end

        it "able to #put update on another family member's event" do
          put "/v1/events/#{@comparable.id}", :params => @update_put_request_params, :headers => @auth_headers
          expected = @update_put_request_params[:event][:attributes]
          actual = JSON.parse(response.body)["data"]["attributes"]
          
          expect(response).to have_http_status(200)
          expect(actual["title"]).to eq(expected["title"])
          expect(actual["description"]).to eq(expected["description"])
          expect(actual["attachment"]).to eq(expected["attachment"])
          expect(actual["event-start"]).to eq(expected["event_start"])
          expect(actual["event-end"]).to eq(expected["event_end"])
          expect(actual["event-allday"]).to eq(expected["event_allday"])

          expect(actual["potluck"]).to eq(expected["potluck"])
          expect(actual["locked"]).to eq(expected["locked"])

          expect(actual["family-id"]).to eq(expected["family_id"])
          expect(actual["member-id"]).to eq(expected["member_id"])

          expect(actual["location"][0]).to be_within(0.000000000009).of(expected["location"][0])
          expect(actual["location"][1]).to be_within(0.000000000009).of(expected["location"][1])
          
          expect(actual["created-at"].to_datetime).to_not eq(expected[:created_at])
          expect(actual["updated-at"].to_datetime).to_not eq(expected[:updated_at])
        end
        it "#patch 200 status and can replace a single attribute and it returns the json for the patched post" do
          patch "/v1/events/#{@comparable.id}", :params => @update_patch_request_params, :headers => @auth_headers
          expected = @update_patch_request_params[:event][:attributes]
          
          json = JSON.parse(response.body)
          actual = json["data"]
          expect(response).to have_http_status(200)
          expect(actual["id"].to_i).to eq(@comparable.id)
          expect(actual["attributes"]["title"]).to eq(expected[:title])
          expect(actual["attributes"]["description"]).to eq(@comparable.description)
          expect(actual["attributes"]["attachment"]).to eq(@comparable.attachment)
          expect(actual["attributes"]["locked"]).to eq(@comparable.locked)
          expect(actual["attributes"]["family-id"]).to eq(@comparable.family_id)
          expect(actual["attributes"]["member-id"]).to eq(@comparable.member_id)

          expect(actual["attributes"]["location"][0]).to be_within(0.000000000009).of(@comparable.location[0])
          expect(actual["attributes"]["location"][1]).to be_within(0.000000000009).of(@comparable.location[1])
        end
      end
      context "GET /events Events#destroy" do
        before(:each) do
          @comparable = FactoryBot.create(:event, family_id: @family.id, member_id: @second_member.id )
        end
        it "able to delete on another family member's recipe" do
          @comparable = FactoryBot.create(:event, family_id: @member_family_id, member_id: @member.id )
          @delete_request_params = {:id => @comparable.id }

          delete "/v1/events/#{@comparable.id}", :params => @delete_request_params, :headers => @auth_headers
          expect(response).to have_http_status(204)
        end
      end
    end # Members / Same Family - Admin Role Describe
    
    describe ':: Members / Unauthorized to Family ::' do
      before do
        authorized_member = FactoryBot.create(:family_member, authorized_at: DateTime.now)
        @authorized_member_family_id = authorized_member.family_id
        @authorized_member = authorized_member.member


        unauthorized_member = FactoryBot.create(:family_member, authorized_at: DateTime.now)
        @unauthorized_member_family_id = unauthorized_member.family_id
        @member = unauthorized_member.member
        login_auth(@member)
      end
      context "GET /events Events#index" do
        before do
          FactoryBot.create_list(:event, 5, family_id: @authorized_member_family_id, member_id: @authorized_member.id)
          @comparable = Event.where(family_id: @authorized_member_family_id) # todo: replace with pundit
        end
        before(:each) do
          @auth_headers = @member.create_new_auth_token
        end
        it "200 and returns 0 events" do
          get '/v1/events', :headers => @auth_headers
          json = JSON.parse(response.body) 
          expected = @comparable
          actual = json["data"]
          expect(actual.count).to_not eq(expected.count)
          expect(actual.count).to eq(0)
          expect(response).to have_http_status(200)
        end
        it '200 and returns 1 event in it\'s own family but can\'t see scoped events' do
          expected = FactoryBot.create(:event, family_id: @unauthorized_member_family_id, member_id: @member.id)
          get '/v1/events', :headers => @auth_headers
          json = JSON.parse(response.body)
          actual = json["data"]
          scoped_post_all = Event.where(family_id: [@unauthorized_member_family_id, @authorized_member_family_id])
          expect(actual.count).to eq(1)
          expect(actual.first["attributes"]["description"]).to eq(expected.description)
          expect(scoped_post_all.count).to eq(6)
        end
      end
      context "GET /events Events#show" do
        before do
          @comparable = FactoryBot.create(:event, family_id: @authorized_member_family_id, member_id: @authorized_member.id) # todo: replace with pundit
          FactoryBot.create(:event, family_id: @unauthorized_member_family_id, member_id: @member.id)
        end
        before(:each) do
          @auth_headers = @member.create_new_auth_token
        end
        it "returns 403 status code on unauthorized access" do
          get "/v1/events/#{@comparable.id}", :headers => @auth_headers
          expect(response).to have_http_status(403)
        end
      end
      context "GET /events Events#create" do
        before do
          @comparable = FactoryBot.build(:event, family_id: @authorized_member_family_id, member_id: @member.id) # todo: replace with pundit
          @create_request_params = {
            "event": {
              "attributes": {
                "title": @comparable.title,
                "location": @comparable.location,
                "family_id": @comparable.family_id,
                "member_id": @comparable.member_id
              }
            }
          }
        end
        before(:each) do
          @auth_headers = @member.create_new_auth_token
        end
        it "unable to create a event in another family" do
          event "/v1/events", :params => @create_request_params, :headers => @auth_headers
          expect(response).to have_http_status(403)
        end
      end
      context "GET /events Events#update" do
        before(:each) do
          @auth_headers = @member.create_new_auth_token
        end
        before do
          @comparable = FactoryBot.create(:event, family_id: @member_family_id, member_id: @member.id )
          update_put = FactoryBot.build(:event, family_id: @member_family_id, member_id: @member.id )
          update_patch = FactoryBot.build(:event, family_id: @member_family_id, member_id: @member.id )
          @update_put_request_params = {
            "id": @comparable.id,
            "event": {
              "id": @comparable.id,
              "attributes": update_put.serializable_hash.except!("id", "created_at", "updated_at").to_json
            }
          }
          @update_patch_request_params = {
            "id": @comparable.id,
            "event": {
              "id": @comparable.id,
              "attributes": {
                "title": update_patch.title
              }
            }
          }
        end
        it "returns 403 error for an unauthorized update put" do
          put "/v1/events/#{@comparable.id}", :params => @update_put_request_params, :headers => @auth_headers
          expect(response).to have_http_status(403)
        end
        it 'returns 403 error for an unauthorized update patch' do
          patch "/v1/events/#{@comparable.id}", :params => @update_patch_request_params, :headers => @auth_headers
          expect(response).to have_http_status(403)
        end
      end
      context "GET /events Events#destroy" do
        before(:each) do
          @auth_headers = @member.create_new_auth_token
        end
        it "returns 403 error for an unauthorized attempt to delete" do
          @comparable = FactoryBot.create(:event, family_id: @authorized_member_family_id, member_id: @authorized_member.id )
          @delete_request_params = {:id => @comparable.id }

          delete "/v1/events/#{@comparable.id}", :params => @delete_request_params, :headers => @auth_headers
          expect(response).to have_http_status(403)
        end
      end
    end # Members / Unauthorized to Family Describe
    
    describe ':: Unknown User ::' do
      before do
        @comparable = FactoryBot.create(:event, family_id: @member_family_id, member_id: @member.id )
        @member = nil
      end
      context "GET /events Events#index" do
        it "returns a 401 error saying they are not authenticated" do
          get '/v1/events'
          expect(response).to have_http_status(401)
        end
      end
      context "GET /events Events#show" do
        it "returns a 401 error saying they are not authenticated" do
          get "/v1/events/#{@comparable.id}"
          expect(response).to have_http_status(401)
        end
      end
      context "POST /events Events#create" do
        it "returns a 401 error saying they are not authenticated" do
          post '/v1/events'
          expect(response).to have_http_status(401)
        end
      end
      context "PUT-PATCH /events Events#update" do
        it "#put returns a 401 error saying they are not authenticated" do
          put "/v1/events/#{@comparable.id}"
          expect(response).to have_http_status(401)
        end
        it "#patch returns a 401 error saying they are not authenticated" do
          patch "/v1/events/#{@comparable.id}"
          expect(response).to have_http_status(401)
        end
      end
      context "GET /events Events#destroy" do
        it "returns a 401 error saying they are not authenticated" do
          delete "/v1/events/#{@comparable.id}"
          expect(response).to have_http_status(401)
        end
      end
    end # Unknown User Describe
  end
  context ':: EventsRsvps' do
    before do
      @event = FactoryBot.create(:event, family_id: @family.id, member_id: FactoryBot.create(:family_member, family_id: @family.id, authorized_at: DateTime.now).id)
      party = []
      5.times do
        party << FactoryBot.create(:family_member, family_id: @family.id, authorized_at: DateTime.now).id
      end
      # Party Size refrences that one RSVP might have the RSVPer, guests inside the family, and an non-family guest.
      # Sum of Party Size across all rsvp records reflect total attendance for the GUI of the event.
      party_size = party.count + 2
      @comparable = FactoryBot.create(:event_rsvp_with_food, event_id: @event.id, member_id: @member.id, party_companions: @party, party_size: 7)
      FactoryBot.create_list(:event_rsvp, 4, event_id: @event.id, member_id: FactoryBot.create(:family_member, family_id: @family.id, authorized_at: DateTime.now).id, party_size: 1)
    end
    describe ':: Members / Same Family ::' do
      before do
        login_auth(@member)
      end
      context "GET /events_rsvps EventsRsvps#index" do
        before(:each) do
          @member.create_new_auth_token
        end
        
        it "200 status top route" do
          get '/v1/events_rsvps', :headers => @auth_headers
          expect(response).to have_http_status(200)
        end
        it "200 status child route" do
          get "/v1/events/#{@event.id}/events_rsvps", :headers => @auth_headers
          expect(response).to have_http_status(200)
        end
        it 'and can get all of the records available to the Member\'s policy via index' do
          get "/v1/events/#{@event.id}/events_rsvps", :headers => @auth_headers
          json = JSON.parse(response.body)
          comp = EventRsvp.where(event_id: @event.id)
          expected = comp.first
          actual = json["data"].first
          expect(actual["id"].to_i).to eq(expected.id)
          expect(json["data"].count).to eq(comp.count)
          expect(response).to have_http_status(200)
        end
      end
      context "GET /events_rsvps EventsRsvps#show" do
        it "200 status" do
          get "/v1/events_rsvps/#{@comparable.id}", :headers => @auth_headers
          expect(response).to have_http_status(200)
        end
        it 'and it shows the event_rsvp requested' do
          get "/v1/events_rsvps/#{@comparable.id}", :headers => @auth_headers
          json = JSON.parse(response.body)
          actual = json["data"]["attributes"]


          expect(response).to have_http_status(200)
          expect(json["data"]["id"].to_i).to eq(@comparable.id)
          expect(actual["party_size"]).to eq(@comparable.party_size)
          expect(actual["rsvp"]).to eq(@comparable.rsvp)
          expect(actual["bringing_food"]).to eq(@comparable.bringing_food)
          expect(actual["recipe_id"]).to eq(@comparable.recipe_id)
          expect(actual["non_recipe_description"]).to eq(@comparable.non_recipe_description)
          expect(actual["event-id"]).to eq(@comparable.event_id)
          expect(actual["member-id"]).to eq(@comparable.member_id)

          expect(actual["serving"]).to eq(@comparable.serving)
          expect(actual["party_companions"]).to eq(@comparable.party_companions)
          expect(actual["rsvp_note"]).to eq(@comparable.rsvp_note)
        end
        it 'shows the relationships and links' do
          get "/v1/events_rsvps#{@comparable.id}", :headers => @auth_headers
          json = JSON.parse(response.body)
          
          actual_event_rsvp_links = json["data"]["links"]
          actual_event_links = json["data"]["relationships"]["event"]["links"]
          actual_member_links = json["data"]["relationships"]["member"]["links"]

          expected_resource = @comparable
          expected_member = @comparable.member

          expect(json["data"]["id"].to_i).to eq(@comparable.id)
          expect(actual_event_rsvp_links["self"]).to include("#{@comparable.id}")

          expect(actual_event_links["related"]).to include("related","#{@comparable.member.id}")
          expect(actual_member_links["related"]).to include("member","#{@comparable.member.id}")
        end
      end
      context "GET /events_rsvps EventsRsvps#create" do
        before(:each) do
          event_rsvp = FactoryBot.build(:event_rsvp_with_food, family_id: @family.id, member_id: @member.id)
          @create_request_params = {
            "event_rsvp": {
              "attributes": event_rsvp.serializable_hash.except!("id", "created_at", "updated_at").to_json
            }
          }
          @auth_headers = @member.create_new_auth_token
        end
        it "200 status with correct type with id that is not nil" do
          post '/v1/events_rsvps', :params => @create_request_params, :headers => @auth_headers
          json = JSON.parse(response.body)["data"]
          type = JSON.parse(response.body)["data"]["type"]
          expect(type.to_s).to eq("event_rsvp")
          expect(json).to include("id")
          expect(json["id"]).to_not eq(nil)
          expect(response).to have_http_status(200)
        end
        it 'and it returns the json for the newly created post' do
          post '/v1/events_rsvps', :params => @create_request_params, :headers => @auth_headers
          actual = JSON.parse(response.body)["data"]["attributes"]
          expected = @create_request_params["event_rsvp"]["attributes"]
          expect(response).to have_http_status(200)

          expect(actual["title"]).to eq(expected["title"])
          expect(actual["description"]).to eq(expected["description"])
          expect(actual["attachment"]).to eq(expected["attachment"])
          expect(actual["event_rsvp-start"]).to eq(expected["event_start"])
          expect(actual["event_rsvp-end"]).to eq(expected["event_end"])
          expect(actual["event_rsvp-allday"]).to eq(expected["event_allday"])

          expect(actual["potluck"]).to eq(expected["potluck"])
          expect(actual["locked"]).to eq(expected["locked"])

          expect(actual["family-id"]).to eq(expected["family_id"])
          expect(actual["member-id"]).to eq(expected["member_id"])

          expect(actual["location"][0]).to be_within(0.000000000009).of(expected["location"][0])
          expect(actual["location"][1]).to be_within(0.000000000009).of(expected["location"][1])
        end
        it 'shows the relationships and links to them in the json package' do
          post '/v1/events_rsvps', :params => @create_request_params, :headers => @auth_headers
          actual = JSON.parse(response.body)["data"]["relationships"]
          expect(actual).to include("member")
        end
      end
      context "PUT - PATCH /events_rsvps/:id Posts#update" do
        before(:each) do
          @auth_headers = @member.create_new_auth_token
          @comparable = FactoryBot.create(:event_rsvp_with_food, family_id: @member_family_id, member_id: @member.id )
          update_put = FactoryBot.build(:event_rsvp_with_food, family_id: @member_family_id, member_id: @member.id )
          update_patch = FactoryBot.build(:event_rsvp_with_food, family_id: @member_family_id, member_id: @member.id )
          @update_put_request_params = {
            "id": @comparable.id,
            "event_rsvp": {
              "id": @comparable.id,
              "attributes": update_put.serializable_hash.except!("id", "created_at", "updated_at").to_json
            }
          }
          @update_patch_request_params = {
            "id": @comparable.id,
            "event_rsvp": {
              "id": @comparable.id,
              "attributes": {
                "title": update_patch.title
              }
            }
          }
        end
        it "#put 200 status and matches the json for the putted post" do
          put "/v1/events_rsvps/#{@comparable.id}", :params => @update_put_request_params, :headers => @auth_headers
          expected = @update_put_request_params[:event_rsvp][:attributes]
          actual = JSON.parse(response.body)["data"]["attributes"]
          
          expect(response).to have_http_status(200)
          expect(actual["title"]).to eq(expected["title"])
          expect(actual["description"]).to eq(expected["description"])
          expect(actual["attachment"]).to eq(expected["attachment"])
          expect(actual["event_rsvp-start"]).to eq(expected["event_start"])
          expect(actual["event_rsvp-end"]).to eq(expected["event_end"])
          expect(actual["event_rsvp-allday"]).to eq(expected["event_allday"])

          expect(actual["potluck"]).to eq(expected["potluck"])
          expect(actual["locked"]).to eq(expected["locked"])

          expect(actual["family-id"]).to eq(expected["family_id"])
          expect(actual["member-id"]).to eq(expected["member_id"])

          expect(actual["location"][0]).to be_within(0.000000000009).of(expected["location"][0])
          expect(actual["location"][1]).to be_within(0.000000000009).of(expected["location"][1])
          
          expect(actual["created-at"].to_datetime).to_not eq(expected[:created_at])
          expect(actual["updated-at"].to_datetime).to_not eq(expected[:updated_at])
        end
        it "#patch 200 status and can replace a single attribute and it returns the json for the patched post" do
          patch "/v1/events_rsvps/#{@comparable.id}", :params => @update_patch_request_params, :headers => @auth_headers
          expected = @update_patch_request_params[:event_rsvp][:attributes]
          
          json = JSON.parse(response.body)
          actual = json["data"]
          expect(response).to have_http_status(200)
          expect(actual["id"].to_i).to eq(@comparable.id)
          expect(actual["attributes"]["title"]).to eq(expected[:title])
          expect(actual["attributes"]["description"]).to eq(@comparable.description)
          expect(actual["attributes"]["attachment"]).to eq(@comparable.attachment)
          expect(actual["attributes"]["locked"]).to eq(@comparable.locked)
          expect(actual["attributes"]["family-id"]).to eq(@comparable.family_id)
          expect(actual["attributes"]["member-id"]).to eq(@comparable.member_id)

          expect(actual["attributes"]["location"][0]).to be_within(0.000000000009).of(@comparable.location[0])
          expect(actual["attributes"]["location"][1]).to be_within(0.000000000009).of(@comparable.location[1])
        end
        it '#patch shows the relationships and links to them in the json package' do
          patch "/v1/events_rsvps/#{@comparable.id}", :params => @update_patch_request_params, :headers => @auth_headers
          actual = JSON.parse(response.body)["data"]["relationships"]
          expect(actual).to include("member")
        end
        it '#put shows the relationships and links to them in the json package' do
          patch "/v1/events_rsvps/#{@comparable.id}", :params => @update_put_request_params, :headers => @auth_headers
          actual = JSON.parse(response.body)["data"]["relationships"]
          expect(actual).to include("member")
        end
      end
      context "GET /events_rsvps EventsRsvps#destroy" do
        before(:each) do
          @auth_headers = @member.create_new_auth_token
        end
        it "can sucessfully delete a event_rsvp" do
          @comparable = FactoryBot.create(:event_rsvp_with_food, family_id: @member_family_id, member_id: @member.id )
          @delete_request_params = {:id => @comparable.id }

          delete "/v1/events_rsvps/#{@comparable.id}", :params => @delete_request_params, :headers => @auth_headers
          expect(response).to have_http_status(204)
        end
        it 'returns 404 for missing content' do
          @comparable = FactoryBot.create(:event_rsvp_with_food, family_id: @member_family_id, member_id: @member.id )
          EventRsvp.find(@comparable.id).destroy
          delete "/v1/events_rsvps/#{@comparable.id}", :params => @delete_request_params, :headers => @auth_headers
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
            @comparable = FactoryBot.create(:event_rsvp_with_food, family_id: @member_family_id, member_id: @second_member.id )
            @updates = FactoryBot.create(:event_rsvp_with_food, family_id: @member_family_id, member_id: @member.id )
          end
          it "unable to #put update on another family member's post" do
            unauthorized_update_put_request_params = {
            "id": @updates.id,
              "event_rsvp": {
                "id": @updates.id,
                "attributes": update_put.serializable_hash.except!("id", "created_at", "updated_at").to_json
              }
            }

            put "/v1/events_rsvps/#{@comparable.id}", :params => unauthorized_update_put_request_params, :headers => @auth_headers
            expect(response).to have_http_status(403)
          end
          it "unable to #patch update on another family member's post" do
            unauthorized_patch_of_event_params = {
              "id": @comparable.id,
              "event_rsvp": {
                "id": @comparable.id,
                "attributes": {
                  "title": @updates.title
                }
              }
            }

            patch "/v1/events_rsvps/#{@comparable.id}", :params => unauthorized_patch_of_event_params, :headers => @auth_headers
            expect(response).to have_http_status(403)
          end
          it "unable to #patch update on a protected field" do
            update_patch_request_unpermitted_params = {
            "id": @updates.id,
              "event_rsvp": {
                "id": @updates.id,
                "attributes": @updates.serializable_hash.except!("title", "description", "attachment", "event_start", "event_end", "event_allday", "location", "potluck", "family_id", "member_id").to_json
              }
            }
            patch "/v1/events_rsvps/#{@comparable.id}", :params => update_patch_request_unpermitted_params, :headers => @auth_headers
            expect(response).to have_http_status(403)
          end
          it "unable to #put update on a protected field" do
            update_put_request_unpermitted_params = {
            "id": @updates.id,
              "event_rsvp": {
                "id": @updates.id,
                "attributes": @updates.serializable_hash.except!("title", "description", "attachment", "event_start", "event_end", "event_allday", "location", "potluck", "family_id", "member_id").to_json
              }
            }
            put "/v1/events_rsvps/#{@comparable.id}", :params => update_put_request_unpermitted_params, :headers => @auth_headers
            expect(response).to have_http_status(403)
          end
        end
        context "DELETE /events_rsvps Posts#delete :: Member 2 => Member 1" do
          before(:each) do
            @auth_headers = @member.create_new_auth_token
          end
          it "unable to delete on another family member's post" do
            @comparable = FactoryBot.create(:event_rsvp_with_food, family_id: @family.id, member_id: FactoryBot.create(:family_member, family_id: @family.id ).member_id )
            delete_request_params = {:id => @comparable.id }
            delete "/v1/events_rsvps/#{@comparable.id}", :params => delete_request_params, :headers => @auth_headers
            expect(response).to have_http_status(403)
          end
        end
      end
    end # Members / Same Family Describe
    
    describe ':: Members / Same Family - Admin Role ::' do
      before do
        @second_member = FactoryBot.create(:family_member, family_id: @family.id, authorized_at: DateTime.now).member
        family_member = FactoryBot.create(:family_member, authorized_at: DateTime.now, user_role: "admin")
        @member = family_member.member
        login(@member)
      end
      context "GET /events_rsvps EventsRsvps#update" do
        before(:each) do
          @auth_headers = @member.create_new_auth_token
          @comparable = FactoryBot.create(:event_rsvp_with_food, family_id: @family.id, member_id: @second_member.id )
          update = FactoryBot.build(:event_rsvp_with_food, family_id: @member_family_id, member_id: @member.id )
          @update_put_request_params = {
            "id": @comparable.id,
            "event_rsvp": {
              "id": @comparable.id,
              "attributes": update.serializable_hash.except!("id", "created_at", "updated_at").to_json
            }
          }
          @update_patch_request_params = {
            "id": @comparable.id,
            "event_rsvp": {
              "id": @comparable.id,
              "attributes": {
                "title": update.title
              }
            }
          }
        end

        it "able to #put update on another family member's event_rsvp" do
          put "/v1/events_rsvps/#{@comparable.id}", :params => @update_put_request_params, :headers => @auth_headers
          expected = @update_put_request_params[:event_rsvp][:attributes]
          actual = JSON.parse(response.body)["data"]["attributes"]
          
          expect(response).to have_http_status(200)
          expect(actual["title"]).to eq(expected["title"])
          expect(actual["description"]).to eq(expected["description"])
          expect(actual["attachment"]).to eq(expected["attachment"])
          expect(actual["event_rsvp-start"]).to eq(expected["event_start"])
          expect(actual["event_rsvp-end"]).to eq(expected["event_end"])
          expect(actual["event_rsvp-allday"]).to eq(expected["event_allday"])

          expect(actual["potluck"]).to eq(expected["potluck"])
          expect(actual["locked"]).to eq(expected["locked"])

          expect(actual["family-id"]).to eq(expected["family_id"])
          expect(actual["member-id"]).to eq(expected["member_id"])

          expect(actual["location"][0]).to be_within(0.000000000009).of(expected["location"][0])
          expect(actual["location"][1]).to be_within(0.000000000009).of(expected["location"][1])
          
          expect(actual["created-at"].to_datetime).to_not eq(expected[:created_at])
          expect(actual["updated-at"].to_datetime).to_not eq(expected[:updated_at])
        end
        it "#patch 200 status and can replace a single attribute and it returns the json for the patched post" do
          patch "/v1/events_rsvps/#{@comparable.id}", :params => @update_patch_request_params, :headers => @auth_headers
          expected = @update_patch_request_params[:event_rsvp][:attributes]
          
          json = JSON.parse(response.body)
          actual = json["data"]
          expect(response).to have_http_status(200)
          expect(actual["id"].to_i).to eq(@comparable.id)
          expect(actual["attributes"]["title"]).to eq(expected[:title])
          expect(actual["attributes"]["description"]).to eq(@comparable.description)
          expect(actual["attributes"]["attachment"]).to eq(@comparable.attachment)
          expect(actual["attributes"]["locked"]).to eq(@comparable.locked)
          expect(actual["attributes"]["family-id"]).to eq(@comparable.family_id)
          expect(actual["attributes"]["member-id"]).to eq(@comparable.member_id)

          expect(actual["attributes"]["location"][0]).to be_within(0.000000000009).of(@comparable.location[0])
          expect(actual["attributes"]["location"][1]).to be_within(0.000000000009).of(@comparable.location[1])
        end
      end
      context "GET /events_rsvps EventsRsvps#destroy" do
        before(:each) do
          @comparable = FactoryBot.create(:event_rsvp_with_food, family_id: @family.id, member_id: @second_member.id )
        end
        it "able to delete on another family member's recipe" do
          @comparable = FactoryBot.create(:event_rsvp_with_food, family_id: @member_family_id, member_id: @member.id )
          @delete_request_params = {:id => @comparable.id }

          delete "/v1/events_rsvps/#{@comparable.id}", :params => @delete_request_params, :headers => @auth_headers
          expect(response).to have_http_status(204)
        end
      end
    end # Members / Same Family - Admin Role Describe
    
    describe ':: Members / Unauthorized to Family ::' do
      before do
        authorized_member = FactoryBot.create(:family_member, authorized_at: DateTime.now)
        @authorized_member_family_id = authorized_member.family_id
        @authorized_member = authorized_member.member


        unauthorized_member = FactoryBot.create(:family_member, authorized_at: DateTime.now)
        @unauthorized_member_family_id = unauthorized_member.family_id
        @member = unauthorized_member.member
        login_auth(@member)
      end
      context "GET /events_rsvps EventsRsvps#index" do
        before do
          FactoryBot.create_list(:event_rsvp_with_food, 5, family_id: @authorized_member_family_id, member_id: @authorized_member.id)
          @comparable = EventRsvp.where(family_id: @authorized_member_family_id) # todo: replace with pundit
        end
        before(:each) do
          @auth_headers = @member.create_new_auth_token
        end
        it "200 and returns 0 events_rsvps" do
          get '/v1/events_rsvps', :headers => @auth_headers
          json = JSON.parse(response.body) 
          expected = @comparable
          actual = json["data"]
          expect(actual.count).to_not eq(expected.count)
          expect(actual.count).to eq(0)
          expect(response).to have_http_status(200)
        end
        it '200 and returns 1 event_rsvp in it\'s own family but can\'t see scoped events_rsvps' do
          expected = FactoryBot.create(:event_rsvp_with_food, family_id: @unauthorized_member_family_id, member_id: @member.id)
          get '/v1/events_rsvps', :headers => @auth_headers
          json = JSON.parse(response.body)
          actual = json["data"]
          scoped_post_all = EventRsvp.where(family_id: [@unauthorized_member_family_id, @authorized_member_family_id])
          expect(actual.count).to eq(1)
          expect(actual.first["attributes"]["description"]).to eq(expected.description)
          expect(scoped_post_all.count).to eq(6)
        end
      end
      context "GET /events_rsvps EventsRsvps#show" do
        before do
          @comparable = FactoryBot.create(:event_rsvp_with_food, family_id: @authorized_member_family_id, member_id: @authorized_member.id) # todo: replace with pundit
          FactoryBot.create(:event_rsvp_with_food, family_id: @unauthorized_member_family_id, member_id: @member.id)
        end
        before(:each) do
          @auth_headers = @member.create_new_auth_token
        end
        it "returns 403 status code on unauthorized access" do
          get "/v1/events_rsvps/#{@comparable.id}", :headers => @auth_headers
          expect(response).to have_http_status(403)
        end
      end
      context "GET /events_rsvps EventsRsvps#create" do
        before do
          @comparable = FactoryBot.build(:event_rsvp_with_food, family_id: @authorized_member_family_id, member_id: @member.id) # todo: replace with pundit
          @create_request_params = {
            "event_rsvp": {
              "attributes": {
                "title": @comparable.title,
                "location": @comparable.location,
                "family_id": @comparable.family_id,
                "member_id": @comparable.member_id
              }
            }
          }
        end
        before(:each) do
          @auth_headers = @member.create_new_auth_token
        end
        it "unable to create a event_rsvp in another family" do
          event_rsvp "/v1/events_rsvps", :params => @create_request_params, :headers => @auth_headers
          expect(response).to have_http_status(403)
        end
      end
      context "GET /events_rsvps EventsRsvps#update" do
        before(:each) do
          @auth_headers = @member.create_new_auth_token
        end
        before do
          @comparable = FactoryBot.create(:event_rsvp_with_food, family_id: @member_family_id, member_id: @member.id )
          update_put = FactoryBot.build(:event_rsvp_with_food, family_id: @member_family_id, member_id: @member.id )
          update_patch = FactoryBot.build(:event_rsvp_with_food, family_id: @member_family_id, member_id: @member.id )
          @update_put_request_params = {
            "id": @comparable.id,
            "event_rsvp": {
              "id": @comparable.id,
              "attributes": update_put.serializable_hash.except!("id", "created_at", "updated_at").to_json
            }
          }
          @update_patch_request_params = {
            "id": @comparable.id,
            "event_rsvp": {
              "id": @comparable.id,
              "attributes": {
                "title": update_patch.title
              }
            }
          }
        end
        it "returns 403 error for an unauthorized update put" do
          put "/v1/events_rsvps/#{@comparable.id}", :params => @update_put_request_params, :headers => @auth_headers
          expect(response).to have_http_status(403)
        end
        it 'returns 403 error for an unauthorized update patch' do
          patch "/v1/events_rsvps/#{@comparable.id}", :params => @update_patch_request_params, :headers => @auth_headers
          expect(response).to have_http_status(403)
        end
      end
      context "GET /events_rsvps EventsRsvps#destroy" do
        before(:each) do
          @auth_headers = @member.create_new_auth_token
        end
        it "returns 403 error for an unauthorized attempt to delete" do
          @comparable = FactoryBot.create(:event_rsvp_with_food, family_id: @authorized_member_family_id, member_id: @authorized_member.id )
          @delete_request_params = {:id => @comparable.id }

          delete "/v1/events_rsvps/#{@comparable.id}", :params => @delete_request_params, :headers => @auth_headers
          expect(response).to have_http_status(403)
        end
      end
    end # Members / Unauthorized to Family Describe
    
    describe ':: Unknown User ::' do
      before do
        @comparable = FactoryBot.create(:event_rsvp_with_food, family_id: @member_family_id, member_id: @member.id )
        @member = nil
      end
      context "GET /events_rsvps EventsRsvps#index" do
        it "returns a 401 error saying they are not authenticated" do
          get '/v1/events_rsvps'
          expect(response).to have_http_status(401)
        end
      end
      context "GET /events_rsvps EventsRsvps#show" do
        it "returns a 401 error saying they are not authenticated" do
          get "/v1/events_rsvps/#{@comparable.id}"
          expect(response).to have_http_status(401)
        end
      end
      context "POST /events_rsvps EventsRsvps#create" do
        it "returns a 401 error saying they are not authenticated" do
          post '/v1/events_rsvps'
          expect(response).to have_http_status(401)
        end
      end
      context "PUT-PATCH /events_rsvps EventsRsvps#update" do
        it "#put returns a 401 error saying they are not authenticated" do
          put "/v1/events_rsvps/#{@comparable.id}"
          expect(response).to have_http_status(401)
        end
        it "#patch returns a 401 error saying they are not authenticated" do
          patch "/v1/events_rsvps/#{@comparable.id}"
          expect(response).to have_http_status(401)
        end
      end
      context "GET /events_rsvps EventsRsvps#destroy" do
        it "returns a 401 error saying they are not authenticated" do
          delete "/v1/events_rsvps/#{@comparable.id}"
          expect(response).to have_http_status(401)
        end
      end
    end # Unknown User Describe
  end
end

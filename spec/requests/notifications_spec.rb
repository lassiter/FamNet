require 'rails_helper'
# Note: When "record" is mentioned in relation to a notification
# that is referring to the record found via notifiable_type and notifiable_id.
RSpec.describe "Notifications", type: :request do
  
  describe ':: Members / Same Family ::' do
    before do
      family_member = FactoryBot.create(:family_member).member
      @member = family_member.member
      
    end
    context "GET /notifications Notifications#index" do
      before(:each) do
      @member.create_new_auth_token
      end
      
      it "works! (now write some real specs)" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(200)
      end
      it 'and can get all of the records available to the Member\'s policy via index' do
        get '/v1/notifications'
        expect(response).to have_http_status(200)
      end
      it 'and getting the index returns the record\'s #show for each notification' do
        get '/v1/notifications'
        expect(response).to have_http_status(200)
      end
      it 'shows the relationships and links to them in the json package' do
        get '/v1/notifications'
        expect(response).to have_http_status(200)
      end
    end
    context "GET /notifications Notifications#show" do
      it "works! (now write some real specs)" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(200)
      end
      it 'and it shows the notification requested' do
        get '/v1/notifications'
        expect(response).to have_http_status(200)
      end
      it 'and it shows the requested notification\'s attached record' do
        get '/v1/notifications'
        expect(response).to have_http_status(200)
      end
      it 'shows the relationships and links to them in the json package' do
        get '/v1/notifications'
        expect(response).to have_http_status(200)
      end
    end
    context "GET /notifications Notifications#create" do
      it "works! (now write some real specs)" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(200)
      end
      it 'and it returns the json for the newly created post' do
        get '/v1/notifications'
        expect(response).to have_http_status(200)
      end
      it 'shows the relationships and links to them in the json package' do
        get '/v1/notifications'
        expect(response).to have_http_status(200)
      end
    end
    context "GET /notifications Notifications#update" do
      it "#put works! (now write some real specs)" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(200)
      end
      it 'and it returns the json for the putted post' do
        get '/v1/notifications'
        expect(response).to have_http_status(200)
      end
      it "#patch can replace a single attribute" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(200)
      end
      it 'and it returns the json for the patched post' do
        get '/v1/notifications'
        expect(response).to have_http_status(200)
      end
      it 'shows the relationships and links to them in the json package' do
        get '/v1/notifications'
        expect(response).to have_http_status(200)
      end
      it "unable to #put update on another family member's recipe" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it "unable to #patch update on another family member's recipe" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
    end
    context "GET /notifications Notifications#destroy" do
      it "works! (now write some real specs)" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(200)
      end
      it 'can sucessfully delete a post' do
        expect(response).to have_http_status(200)
      end
      xit 'returns 404 for missing content' do
        expect(response).to have_http_status(404)
      end
      it "unable to delete on another family member's recipe" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
    end
    context "GET /notifications Notifications#search" do
      it "works! (now write some real specs)" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(200)
      end
      it "returns unprocessible entity if type doesn't match" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it "can return a notification by tag matches" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(200)
      end
      it "can return a notification by notification name matches" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(200)
      end
      it "can return a notification by ingredient matches" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(200)
      end
    end

  end # Members / Same Family Describe
  
  describe ':: Members / Same Family - Admin Role ::' do
    before do
      family_member = FactoryBot.create(:family_member).member
      @member = family_member.member
      
    end
    context "GET /notifications Notifications#update" do
      it "able to #put update on another family member's recipe" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it "able to #patch update on another family member's recipe" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
    end
    context "GET /notifications Notifications#destroy" do
      it "able to delete on another family member's recipe" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
    end
  end # Members / Same Family - Admin Role Describe
  
  describe ':: Members / Unauthorized to Family ::' do
    before do
      non_family = FactoryBot.create(:family_member)
      @non_family_member = non_family.member
      FactoryBot.create_list(:recipe, 5)
      @member = FactoryBot.create(:family_member).member
    end
    context "GET /notifications Notifications#index" do
      it "works! (now write some real specs)" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it 'and can get all of the records available to the Member\'s policy via index' do
        get '/v1/notifications'
        expect(response).to have_http_status(403)
      end
      it 'and getting the index returns the count and type of reactions for each record' do
        get '/v1/notifications'
        expect(response).to have_http_status(403)
      end
      it 'shows the relationships and links to them in the json package' do
        get '/v1/notifications'
        expect(response).to have_http_status(403)
      end
    end
    context "GET /notifications Notifications#show" do
      it "works! (now write some real specs)" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it 'and it shows the notification requested' do
        get '/v1/notifications'
        expect(response).to have_http_status(403)
      end
      it 'and it shows the requested recipe\'s comments and reactions' do
        get '/v1/notifications'
        expect(response).to have_http_status(403)
      end
      it 'shows the relationships and links to them in the json package' do
        get '/v1/notifications'
        expect(response).to have_http_status(403)
      end
    end
    context "GET /notifications Notifications#create" do
      it "works! (now write some real specs)" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it 'and it returns the json for the newly created post' do
        get '/v1/notifications'
        expect(response).to have_http_status(403)
      end
      it 'shows the relationships and links to them in the json package' do
        get '/v1/notifications'
        expect(response).to have_http_status(403)
      end
    end
    context "GET /notifications Notifications#update" do
      it "#put works! (now write some real specs)" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it 'and it returns the json for the putted post' do
        get '/v1/notifications'
        expect(response).to have_http_status(403)
      end
      it "#patch can replace a single attribute" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it 'and it returns the json for the patched post' do
        get '/v1/notifications'
        expect(response).to have_http_status(403)
      end
      it 'shows the relationships and links to them in the json package' do
        get '/v1/notifications'
        expect(response).to have_http_status(403)
      end
    end
    context "GET /notifications Notifications#destroy" do
      it "works! (now write some real specs)" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it 'can sucessfully delete a post' do
        expect(response).to have_http_status(403)
      end
      xit 'returns 404 for missing content' do
        expect(response).to have_http_status(403)
      end
    end
    context "GET /notifications Notifications#search" do
      it "works! (now write some real specs)" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it "returns unprocessible entity if type doesn't match" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it "can return a notification by tag matches" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it "can return a notification by notification name matches" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it "can return a notification by ingredient matches" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
    end

  end # Members / Unauthorized to Family Describe
  
  describe ':: Unknown User ::' do
    before do
      @member = nil
    end
    context "GET /notifications Notifications#index" do
      it "returns a 401 error saying they are not authenticated" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(401)
      end
    end
    context "GET /notifications Notifications#show" do
      it "returns a 401 error saying they are not authenticated" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(401)
      end
    end
    context "GET /notifications Notifications#create" do
      it "returns a 401 error saying they are not authenticated" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(401)
      end
    end
    context "GET /notifications Notifications#update" do
      it "#put returns a 401 error saying they are not authenticated" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(401)
      end
      it "#patch returns a 401 error saying they are not authenticated" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(401)
      end
    end
    context "GET /notifications Notifications#destroy" do
      it "returns a 401 error saying they are not authenticated" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(401)
      end
    end
    context "GET /notifications Notifications#search" do
      it "returns a 401 error saying they are not authenticated" do
        get '/v1/notifications'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(401)
      end
    end

  end # Unknown User Describe

  describe ':: Notifications Functionality ::' do
    context 'Testing Posts ::' do
      it 'each mentioned member in the resource body gets a mention notificaiton' do
        
      end
    end
    context 'Testing Recipes ::' do
      it 'each mentioned member in the resource body gets a mention notificaiton' do
        
      end
    end
    context 'Testing Events ::' do
      it 'each mentioned member in the resource body gets a mention notificaiton' do
        
      end
    end
    context 'Testing EventsRsvp ::' do
      it 'creates a notification for the each RSVP\'d member of the Event' do
        
      end
      it 'creates a notification for the Event Host' do
        
      end
    end
    context 'Testing Comments ::' do
      it 'each mentioned member in the resource body gets a mention notificaiton' do
        
      end
      it 'creates a notification for the member of the parent resource' do
        
      end
      it 'creates a notification for the members of sibiling Comments under the resource' do
        
      end
    end
    context 'Testing CommentReplys ::' do
      it 'each mentioned member in the resource body gets a mention notificaiton' do
        
      end
      it 'creates a notification for the member of the parent Comment' do
        
      end
      it 'creates a notification for the members of sibiling CommentReplys under the Comment' do
        
      end
    end
    context 'Testing Reactions ::' do
      it 'creates a notification for the member of the Reacted resource' do
        
      end
    end
    context 'Testing FamilyMember ::' do
      it 'creates a notification for each FamilyMember on FamilyMember commit' do
        
      end
    end
  end
  
end # notification RSpec

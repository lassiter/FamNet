require 'rails_helper'

RSpec.describe "Recipes", type: :request do
  
  describe ':: Members / Same Family ::' do
    before do
      family_member = FactoryBot.create(:family_member).member
      @member = family_member.member
      
    end
    context "GET /recipes Recipes#index" do
      before(:each) do
      @member.create_new_auth_token
      end
      
      it "works! (now write some real specs)" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(200)
      end
      it 'and can get all of the records available to the Member\'s policy via index' do
        get '/v1/recipes'
        expect(response).to have_http_status(200)
      end
      it 'and getting the index returns the count and type of reactions for each record' do
        get '/v1/recipes'
        expect(response).to have_http_status(200)
      end
      it 'shows the relationships and links to them in the json package' do
        get '/v1/recipes'
        expect(response).to have_http_status(200)
      end
    end
    context "GET /recipes Recipes#show" do
      it "works! (now write some real specs)" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(200)
      end
      it 'and it shows the recipe requested' do
        get '/v1/recipes'
        expect(response).to have_http_status(200)
      end
      it 'and it shows the requested recipe\'s comments and reactions' do
        get '/v1/recipes'
        expect(response).to have_http_status(200)
      end
      it 'shows the relationships and links to them in the json package' do
        get '/v1/recipes'
        expect(response).to have_http_status(200)
      end
    end
    context "GET /recipes Recipes#create" do
      it "works! (now write some real specs)" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(200)
      end
      it 'and it returns the json for the newly created post' do
        get '/v1/recipes'
        expect(response).to have_http_status(200)
      end
      it 'shows the relationships and links to them in the json package' do
        get '/v1/recipes'
        expect(response).to have_http_status(200)
      end
    end
    context "GET /recipes Recipes#update" do
      it "#put works! (now write some real specs)" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(200)
      end
      it 'and it returns the json for the putted post' do
        get '/v1/recipes'
        expect(response).to have_http_status(200)
      end
      it "#patch can replace a single attribute" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(200)
      end
      it 'and it returns the json for the patched post' do
        get '/v1/recipes'
        expect(response).to have_http_status(200)
      end
      it 'shows the relationships and links to them in the json package' do
        get '/v1/recipes'
        expect(response).to have_http_status(200)
      end
      it "unable to #put update on another family member's recipe" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it "unable to #patch update on another family member's recipe" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
    end
    context "GET /recipes Recipes#destroy" do
      it "works! (now write some real specs)" do
        get '/v1/recipes'
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
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
    end
    context "GET /recipes Recipes#search" do
      it "works! (now write some real specs)" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(200)
      end
      it "returns unprocessible entity if type doesn't match" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it "can return a recipe by tag matches" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(200)
      end
      it "can return a recipe by recipe name matches" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(200)
      end
      it "can return a recipe by ingredient matches" do
        get '/v1/recipes'
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
    context "GET /recipes Recipes#update" do
      it "able to #put update on another family member's recipe" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it "able to #patch update on another family member's recipe" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
    end
    context "GET /recipes Recipes#destroy" do
      it "able to delete on another family member's recipe" do
        get '/v1/recipes'
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
    context "GET /recipes Recipes#index" do
      it "works! (now write some real specs)" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it 'and can get all of the records available to the Member\'s policy via index' do
        get '/v1/recipes'
        expect(response).to have_http_status(403)
      end
      it 'and getting the index returns the count and type of reactions for each record' do
        get '/v1/recipes'
        expect(response).to have_http_status(403)
      end
      it 'shows the relationships and links to them in the json package' do
        get '/v1/recipes'
        expect(response).to have_http_status(403)
      end
    end
    context "GET /recipes Recipes#show" do
      it "works! (now write some real specs)" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it 'and it shows the recipe requested' do
        get '/v1/recipes'
        expect(response).to have_http_status(403)
      end
      it 'and it shows the requested recipe\'s comments and reactions' do
        get '/v1/recipes'
        expect(response).to have_http_status(403)
      end
      it 'shows the relationships and links to them in the json package' do
        get '/v1/recipes'
        expect(response).to have_http_status(403)
      end
    end
    context "GET /recipes Recipes#create" do
      it "works! (now write some real specs)" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it 'and it returns the json for the newly created post' do
        get '/v1/recipes'
        expect(response).to have_http_status(403)
      end
      it 'shows the relationships and links to them in the json package' do
        get '/v1/recipes'
        expect(response).to have_http_status(403)
      end
    end
    context "GET /recipes Recipes#update" do
      it "#put works! (now write some real specs)" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it 'and it returns the json for the putted post' do
        get '/v1/recipes'
        expect(response).to have_http_status(403)
      end
      it "#patch can replace a single attribute" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it 'and it returns the json for the patched post' do
        get '/v1/recipes'
        expect(response).to have_http_status(403)
      end
      it 'shows the relationships and links to them in the json package' do
        get '/v1/recipes'
        expect(response).to have_http_status(403)
      end
    end
    context "GET /recipes Recipes#destroy" do
      it "works! (now write some real specs)" do
        get '/v1/recipes'
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
    context "GET /recipes Recipes#search" do
      it "works! (now write some real specs)" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it "returns unprocessible entity if type doesn't match" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it "can return a recipe by tag matches" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it "can return a recipe by recipe name matches" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(403)
      end
      it "can return a recipe by ingredient matches" do
        get '/v1/recipes'
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
    context "GET /recipes Recipes#index" do
      it "returns a 401 error saying they are not authenticated" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(401)
      end
    end
    context "GET /recipes Recipes#show" do
      it "returns a 401 error saying they are not authenticated" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(401)
      end
    end
    context "GET /recipes Recipes#create" do
      it "returns a 401 error saying they are not authenticated" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(401)
      end
    end
    context "GET /recipes Recipes#update" do
      it "#put returns a 401 error saying they are not authenticated" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(401)
      end
      it "#patch returns a 401 error saying they are not authenticated" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(401)
      end
    end
    context "GET /recipes Recipes#destroy" do
      it "returns a 401 error saying they are not authenticated" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(401)
      end
    end
    context "GET /recipes Recipes#search" do
      it "returns a 401 error saying they are not authenticated" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        header = JSON.parse(response.header)
        expect(response).to have_http_status(401)
      end
    end

  end # Unknown User Describe

end # Recipe RSpec

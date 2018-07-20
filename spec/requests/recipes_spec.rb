require 'rails_helper'

RSpec.describe "Recipes", type: :request do
  
  describe ':: Members / Same Family ::' do
    before do
      @family = FactoryBot.create(:family)
      family_member = FactoryBot.create(:family_member, family_id: @family.id, authorized_at: DateTime.now)
      second_family_member = FactoryBot.create(:family_member, family_id: @family.id, authorized_at: DateTime.now)
      @second_member = second_family_member.member
      @member = family_member.member

      # Recipe Factory
      @recipe_list = []
      5.times do
        ingredients_array = []
        tags_array = []
        recipe = FactoryBot.create(:recipe, member_id: @second_member.id, ingredients_list: [],tags_list: [] )
          rand(1..3).times do
            new_tag = FactoryBot.create(:tag, mature: false)
            FactoryBot.create(:recipe_tag, tag_id: new_tag.id, recipe_id: recipe.id)
            tags_array << new_tag.title.to_s
          end
          rand(3..5).times do
            new_ingredient = FactoryBot.create(:ingredient)
            FactoryBot.create(:recipe_ingredient, ingredient_id: new_ingredient.id, recipe_id: recipe.id)
            ingredients_array << new_ingredient.title.to_s
          end
        recipe.update_attributes(ingredients_list: ingredients_array, tags_list: tags_array)
      @recipe_list << recipe
      end
      login_auth(@member)
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
      before(:each) do
        create_tags_list = [
          {"title": "; DROP TABLE RECIPES; --"},{"title": "foobaz", "description": Faker::Lorem.sentence},{"title": "italian", "description": "Cultural food deriving from italy", "mature": true}
        ]
        ingredient_list = []
        rand(6..9).times do
          item = Faker::Food.ingredient
          ingredient_list << item if !item.nil?
        end
        prep_step = []
        cooking_step = []
        post_step = []

        6.times do |i|
          prep = ["; DROP TABLE RECIPES; --","stir", "masage", "whip",]
          cooking = ["bake", "saute", "grill"]
          post = ["combine", "toss"]
          # Prep
          if i <= 1
            prep_step_task = "Take #{ingredient_list[i]} and #{prep[i]} it till it's you think it's ready."
            prep_step_array_item = {:instruction => prep_step_task, :time_length => "#{rand(1..90)} minutes", :ingredients => [ingredient_list[i]]}
            prep_step.push(prep_step_array_item)
          elsif i >= 2 && i <= 4
            num = rand(0..1)
            cooking_step_task = "Take #{ingredient_list[i]} and combine it with #{ingredient_list[num]} and #{cooking[i]} it till it's done."
            cooking_step_array_item = {:instruction => cooking_step_task, :time_length => "#{rand(1..90)} minutes", :ingredients => [ingredient_list[i], ingredient_list[num]]}
            cooking_step.push(cooking_step_array_item)
          else
            post_step_task = "Take #{ingredient_list.slice(0..1).join(', ')} and #{ingredient_list[2]} then #{post.sample} it with #{ingredient_list[-1]}."
            post_step_array_item = {:instruction => post_step_task, :time_length => "#{rand(1..90)} minutes", :ingredients => ingredient_list[0..2].push(ingredient_list[-1])}
            post_step.push(post_step_array_item)
          end
        end
        steps = {"preparation" => prep_step, "cooking" => cooking_step, "post_cooking" => post_step}

        @recipe = FactoryBot.build(:recipe, steps: steps, member_id: @member.id, ingredients_list: ingredient_list)
        @create_request_params = {
            "title": @recipe.title,
            "description": @recipe.description,
            "member_id": @recipe.member_id,
            "ingredients_list": @recipe.ingredients_list, 
            "steps": steps, 
            "tags_list": create_tags_list
          }
        @auth_headers = @member.create_new_auth_token
      end
      it "200 status of correct type" do
        post '/v1/recipes', :params => {recipe: @create_request_params}, :headers => @auth_headers
        actual = JSON.parse(response.body)["data"]
        expect(response).to have_http_status(200)
        expect(actual["type"]).to eq("recipe")
        expect(actual).to include("id")

      end
      it 'and it returns the json for the newly created post following schema' do
        post '/v1/recipes', :params => {recipe: @create_request_params}, :headers => @auth_headers
        actual = JSON.parse(response.body)["data"]["attributes"]
        expected = @create_request_params
        expect(response).to have_http_status(200)

        expect(actual["title"]).to eq(expected[:title])
        expect(actual["description"]).to eq(expected[:description])
        expect(actual["member-id"]).to eq(expected[:member_id])
        expect(actual["attachment"]).to eq(expected[:attachment])
        expect(actual["tags-list"].first).to_not eq(expected[:tags_list].pluck(:title).first) # "; Drop Table Recipes;   " vs "; DROP TABLE RECIPES; --"
        expect(actual["tags-list"].second_to_last.downcase).to eq(expected[:tags_list].pluck(:title).second_to_last.downcase)
        expect(actual["tags-list"].last.downcase).to eq(expected[:tags_list].pluck(:title).last.downcase)
        expect(actual["ingredients-list"]).to eq(expected[:ingredients_list])

        actual_steps = actual["steps"]
        expect(actual_steps).to include("preparation")
        expect(actual_steps).to include("cooking")
        expect(actual_steps).to include("post-cooking")

        actual_steps_example = actual["steps"]["preparation"].first
        expected_example = @create_request_params[:steps]["preparation"].first
        expect(actual_steps_example["instruction"]).to eq(expected_example[:instruction])
        expect(actual_steps_example["time-length"]).to eq(expected_example[:time_length])
        expect(actual_steps_example["ingredients"]).to eq(expected_example[:ingredients])
      end
      it 'shows the relationships and links to them in the json package' do
        post '/v1/recipes', :params => {recipe: @create_request_params}, :headers => @auth_headers
        actual = JSON.parse(response.body)["data"]
        actual_relationships = actual["relationships"]
        actual_links = actual["links"]
        expect(response).to have_http_status(200)
        expect(actual_relationships).to include("member")
        expect(actual_relationships).to include("tags")
        expect(actual_relationships).to include("ingredients")

        expect(actual_links["self"]).to eq(Rails.application.routes.url_helpers.api_v1_recipes_url(id: actual["id"]))
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
      before(:each) do
        @auth_headers = @member.create_new_auth_token
      end
      it "200 request" do
        query_value = @recipe_list.first.tags_list.first
        get '/v1/recipes/search', params: {filter: {:type => :tag, :query => query_value}}, headers: @auth_headers
        expect(response).to have_http_status(200)
      end
      it "returns unprocessible entity if type doesn't match" do
        query_value = @recipe_list.first.tags_list.first
        get '/v1/recipes/search', params: {filter: {:type => :name, :query => query_value}}, headers: @auth_headers
        expect(response).to have_http_status(:bad_request)
      end
      it "can return a recipe by tag title match" do
        query_value = @recipe_list.second.tags_list.first
        get '/v1/recipes/search', params: {filter: {:type => :tag, :query => query_value}}, headers: @auth_headers
        json = JSON.parse(response.body)["data"]
        actual_tag_list = json.first["attributes"]["tags-list"]
        actual_tags = json.first["relationships"]["tags"]["data"]
        expect(response).to have_http_status(200)

        query_tag_match = 0
        actual_tags.each do |data|
          tag_actual_title = Tag.find(data["id"].to_i).title
          query_tag_match = query_tag_match + 1 if tag_actual_title === query_value
        end
        expect(query_tag_match).to be >= 1
        expect(actual_tag_list).to include(query_value)
      end
      it "can return a recipe by tag description partial" do
        selected_tag = @recipe_list.second.tags.first
        query_value = selected_tag.description.split(" ")[1..3].join(" ")
        get '/v1/recipes/search', params: {filter: {:type => :tag, :query => query_value}}, headers: @auth_headers
        json = JSON.parse(response.body)["data"]
        actual_tag_list = json.first["attributes"]["tags-list"]
        actual_tags = json.first["relationships"]["tags"]["data"]
        expect(response).to have_http_status(200)
        expect(selected_tag.description).to include(query_value) # self validate

        query_tag_match = 0
        expected_tag_id = nil
        actual_tags.each do |data|
          tag_actual_description = Tag.find(data["id"].to_i).description
          query_tag_match = query_tag_match + 1 if tag_actual_description.include?(query_value)
          expected_tag_id = data["id"].to_i if tag_actual_description.include?(query_value)
        end
        expect(query_tag_match).to be >= 1
        expect(expected_tag_id).to eq(selected_tag.id)
        expect(actual_tag_list).to include(selected_tag.title)
      end
      it "can return a recipe by recipe title match" do
        query_value = @recipe_list.third.title
        get '/v1/recipes/search', params: {filter: {:type => :recipe, :query => query_value}}, headers: @auth_headers
        json = JSON.parse(response.body)["data"]
        actual_title = json.first["attributes"]["title"]
        expect(response).to have_http_status(200)
        expect(actual_title).to eq(query_value)
      end
      it "can return a recipe by recipe description partial" do
        selected_recipe = @recipe_list.third
        query_value = selected_recipe.description.split(" ")[1..3].join(" ")
        get '/v1/recipes/search', params: {filter: {:type => :recipe, :query => query_value}}, headers: @auth_headers
        json = JSON.parse(response.body)["data"]
        actual_description = json.first["attributes"]["description"]
        expect(response).to have_http_status(200)
        expect(selected_recipe.description).to include(query_value) # self validate
        expect(actual_description).to include(query_value)
      end
      it "can return a recipe by ingredient title match" do
        query_value = @recipe_list.fourth.ingredients_list.first
        get '/v1/recipes/search', params: {filter: {:type => :ingredient, :query => query_value}}, headers: @auth_headers
        json = JSON.parse(response.body)["data"]
        actual_ingredient_list = json.first["attributes"]["ingredients-list"]
        actual_ingredients = json.first["relationships"]["ingredients"]["data"]
        expect(response).to have_http_status(200)

        query_ingredient_match = 0
        actual_ingredients.each do |data|
          ingredient_actual_title = Ingredient.find(data["id"].to_i).title
          query_ingredient_match = query_ingredient_match + 1 if ingredient_actual_title === query_value
        end
        expect(query_ingredient_match).to be >= 1
        expect(actual_ingredient_list).to include(query_value)
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
      @member = FactoryBot.create(:family_member).member
      @non_family_recipe = FactoryBot.create(:recipe, member_id: @member.id, title: @recipe_list.first.title)
    end
    context "GET /recipes Recipes#index" do
      it "works! (now write some real specs)" do
        get '/v1/recipes'
        json = JSON.parse(response.body) 
        expect(response).to have_http_status(200)
        expect(json.count).to eq(1)
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
    context "GET /recipes Recipes#search" do
      it "can return a recipe by recipe title match that is scoped" do
        query_value = @recipe_list.first.title
        get '/v1/recipes/search', params: {filter: {:type => :recipe, :query => query_value}}, headers: @auth_headers
        json = JSON.parse(response.body)["data"]
        actual = json.first
        actual_title = actual["attributes"]["title"]
        expect(response).to have_http_status(200)
        expect(actual["id"]).to eq(@non_family_recipe.id)
        expect(actual_title).to eq(query_value)
        expect(json.count).to eq(1)
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


  end # Members / Unauthorized to Family Describe
  
  describe ':: Unknown User ::' do
    before do
      @member = nil
    end
    context "GET /recipes Recipes#index" do
      it "returns a 401 error saying they are not authenticated" do
        get '/v1/recipes'
        expect(response).to have_http_status(401)
      end
    end
    context "GET /recipes Recipes#show" do
      it "returns a 401 error saying they are not authenticated" do
        get '/v1/recipes'
        expect(response).to have_http_status(401)
      end
    end
    context "GET /recipes Recipes#create" do
      it "returns a 401 error saying they are not authenticated" do
        get '/v1/recipes'
        expect(response).to have_http_status(401)
      end
    end
    context "GET /recipes Recipes#update" do
      it "#put returns a 401 error saying they are not authenticated" do
        get '/v1/recipes'
        expect(response).to have_http_status(401)
      end
      it "#patch returns a 401 error saying they are not authenticated" do
        get '/v1/recipes'
        expect(response).to have_http_status(401)
      end
    end
    context "GET /recipes Recipes#destroy" do
      it "returns a 401 error saying they are not authenticated" do
        get '/v1/recipes'
        expect(response).to have_http_status(401)
      end
    end
    context "GET /recipes Recipes#search" do
      it "returns a 401 error saying they are not authenticated" do
        get '/v1/recipes'
        expect(response).to have_http_status(401)
      end
    end

  end # Unknown User Describe

end # Recipe RSpec

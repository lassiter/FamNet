
require "rails_helper"
require "recipe_factory"

# This is a two-step factory that loops using find_or_create_by to create/locate
# Ingredients and Tags initally returning a valid Recipe.new record to 
# the Recipe Controller. The callback takes the newly saved recipe_id to create
# join tables to the save recipe. @new_recipe_params is the format the factory 
# takes after converting the params to a hash. The formatting for the steps
# takes place on the front end.

RSpec.describe RecipeFactory do
  before do
    @member = FactoryBot.create(:family_member).member
    @new_recipe_params = {
      "title"=>"Risotto with seafood",
      "description"=>"Vel modi itaque voluptates nulla nam ea placeat.",
      "member_id"=>@member.id.to_s,
      "ingredients_list"=>["CarobCarrot", "Rose Water", "Star Fruit", "Custard ApplesDaikon", "Pine Nut", "Mountain Bread"],
      "tags_list"=>[
        {"title"=>"foobar"}, 
        {"title"=>"foobaz", "description"=>"Illo qui assumenda dolorem ut id quisquam et."}, 
        {"title"=>"italian", "description"=>"Cultural food deriving from italy", "mature"=>"true"}
      ],
      "steps"=>
        {"preparation"=>[
          {"instruction"=>"Take CarobCarrot and foobar it till it's you think it's ready.", "time_length"=>"80 minutes", "ingredients"=>["CarobCarrot"]},
          {"instruction"=>"Take Rose Water and stir it till it's you think it's ready.", "time_length"=>"62 minutes", "ingredients"=>["Rose Water"]}
        ],
        "cooking"=>[
          {"instruction"=>"Take Star Fruit and combine it with CarobCarrot and grill it till it's done.", "time_length"=>"25 minutes", "ingredients"=>["Star Fruit", "CarobCarrot"]},
          {"instruction"=>"Take Custard ApplesDaikon and combine it with CarobCarrot and  it till it's done.", "time_length"=>"10 minutes", "ingredients"=>["Custard ApplesDaikon", "CarobCarrot"]},
          {"instruction"=>"Take Pine Nut and combine it with CarobCarrot and  it till it's done.", "time_length"=>"72 minutes", "ingredients"=>["Pine Nut", "CarobCarrot"]}
        ],
        "post_cooking"=>[
          {"instruction"=>"Take CarobCarrot, Rose Water and Star Fruit then combine it with Mountain Bread.", "time_length"=>"89 minutes", "ingredients"=>["CarobCarrot", "Rose Water", "Star Fruit", "Mountain Bread"]}
        ]
      }
    }
  end
  describe "Inital formatting of recipe based on inputs" do
    it "it takes the params and converts it into a pre-save recipe record to serve the controller" do
      recipe = RecipeFactory.new(@new_recipe_params).result
      expect(recipe.instance_of?(Recipe)).to be true
      expect(recipe.valid?).to be true
      expect(recipe.save).to be true
    end
    it "it takes the params and creates the relevant tags and ingredients for the recipe callback" do
      recipe = RecipeFactory.new(@new_recipe_params).result
      tags = Tag.all
      expect(tags.count).to eq(@new_recipe_params["tags_list"].count)
      @new_recipe_params["tags_list"].each do |tag_hash|
        expect(tags.pluck(:title)).to include(tag_hash["title"].titleize)
        expect(tags.pluck(:description).any? {|description| description = tag_hash["description"].titleize }).to eq(true) if tag_hash["description"].present?
        expect(tags.first.mature && tags.first.mature).to eq(false)
        expect(tags.last.mature).to eq(true)
      end
      ingredients = Ingredient.all
      expect(ingredients.count).to eq(@new_recipe_params["ingredients_list"].count)
      @new_recipe_params["ingredients_list"].each do |ingredient|
        expect(ingredients.pluck(:title)).to include(ingredient)
      end
    end
  end
  describe 'factory callback' do
    before do
      @recipe_to_callback = RecipeFactory.new(@new_recipe_params).result
      @recipe_to_callback.save
    end
    it 'creates the join tables with the new recipe id from the callback' do
      @calledback_recipe_array = RecipeFactory.new(@new_recipe_params).factory_callback(@recipe_to_callback.id)
      expect(@recipe_to_callback.ingredients_list.count + @recipe_to_callback.tags_list.count).to eq(@calledback_recipe_array.count)
      @calledback_recipe_array.each do |record|
        expect(record.instance_of?(RecipeTag) || record.instance_of?(RecipeIngredient)).to be true
        expect(@recipe_to_callback.id).to eq(record.recipe_id)
        if record.instance_of?(RecipeTag)
          expect(@recipe_to_callback.tags_list).to include(record.tag.title)
          expect(@recipe_to_callback.tags.pluck(:title)).to include(record.tag.title)
        elsif record.instance_of?(RecipeIngredient)
          expect(@recipe_to_callback.ingredients_list).to include(record.ingredient.title)
          expect(@recipe_to_callback.ingredients.pluck(:title)).to include(record.ingredient.title)
        end
      end
    end
  end
end
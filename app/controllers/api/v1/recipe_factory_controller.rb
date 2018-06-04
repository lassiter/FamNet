class API::V1::RecipeFactoryController < ApplicationController
require 'pry'
require 'pry-byebug'
  def initialize(recipe_params)
    @title = recipe_params["title"].to_s                                              # string

    @description = recipe_params["description"].to_s      
    
    @ingredients_object_array = []
    @ingredients = recipe_params["ingredients_list"].to_a.each do |ingredient|             # array
      i = Ingredient.find_or_create_by(title: ingredient)

      @ingredients_object_array << i
    end
    
    @tags_object_array = []
    binding.pry
    @tags = recipe_params["tags_list"].each do |tag|   
      t = tag
      tag = Tag.find_or_create_by(title: tag["title"].titleize)
      if tag.description == nil
        tag.description = t["description"]
      end
      if tag.mature == true
        tag.mature = t["mature"]
      end
      @tags_object_array << tag   
    end

    @steps = recipe_params["steps"]                                              # json
    
    @member = Member.find(recipe_params["member_id"].to_i)                            # object

  end
  
  def result
    binding.pry
    Recipe.new({
      title: @title, # string
      description: @description, # text
      member_id: @member.id,
      steps: @steps.to_h,
      attachment: nil,
      ingredients_list: @ingredients_object_array.map {|ingredient| ingredient.title},
      tags_list: @tags_object_array.map {|tag| tag.title},
      ingredients: @ingredients_object_array,
      tags: @tags_object_array
    })
  end

  # def factory_callback(id)
    
  #   @tags_object_array.each do |tag|
  #     RecipeTags.create(tag_id: tag.id, recipe_id: id)
  #   end

  #   @ingredient_object_array.each do |ingredient|
  #     RecipeIngredient.create(ingredient_id: ingredient.id, recipe_id: id)
  #   end

  # end

end
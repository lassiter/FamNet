class API::V1::RecipeFactoryController < ApplicationController

  def initialize(recipe_params)
    puts recipe_params
    @title = recipe_params["title"]                                              # string
    puts @title
    @description = recipe_params["description"]                                 # text
    puts @description
    @ingredients = recipe_params["ingredients"].each do |ingredient|             # array
      Ingredient.find_or_create_by(title: ingredient)
    end
    puts @ingredients
    @steps = recipe_params["steps"]                                              # json
    puts @steps
    binding.pry
    @author = Member.find(recipe_params["member_id"].to_i)                            # object
    puts @author
    @tags = recipe_params["tags"].each do |tag|                                  # array
      puts @tags
      Tag.find_or_create_by(title: tag.title)
      tag.description = tag.description if tag.exists?(self.description)
      tag.mature = tag.mature if tag.exists?(self.mature)
    end
    binding.pry
  end
  def result
    Recipe.new({
      name: @title, # string
      description: @description, # text
      author: @author,
      ingredients: @ingredients, # array
      steps: @steps,
      tags: @tags
    })
  end
  def factory_callback(id)
    @tags.each do |tag|
      RecipeTags.create(tag_id: tag.id, recipe_id: id)
    end
    @ingredients.each do |ingredient|
      RecipeIngredient.create(ingredient_id: ingredient.id, recipe_id: id)
    end
  end

end

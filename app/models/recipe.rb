class Recipe < ApplicationRecord
  include Interaction
  include Commentable
  
  belongs_to :member

  has_many :recipe_ingredients, :class_name => 'RecipeIngredient'
  has_many :ingredients, through: :recipe_ingredients
  has_many :recipe_tags, :class_name => 'RecipeTag'
  has_many :tags, through: :recipe_tags

  def mentioned_members
    MentionParser.new(body).members
  end
end

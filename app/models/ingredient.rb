class Ingredient < ApplicationRecord
  has_many :recipe_ingredients, :class_name => 'RecipeIngredient'
  has_many :recipes, through: :recipe_ingredients
end

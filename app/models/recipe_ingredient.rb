class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient

  validates_presence_of :recipe_id
  validates_presence_of :ingredient_id
end

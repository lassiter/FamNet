class Recipe < ApplicationRecord
  belongs_to :member

  has_many :recipe_ingredients
  has_many :ingredients, through: :recipe_ingredients
  has_many :recipe_tags
  has_many :ingredients, through: :recipe_tags

end

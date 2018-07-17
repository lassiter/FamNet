class Tag < ApplicationRecord
  has_many :recipe_tags, :class_name => 'RecipeTag'
  has_many :recipes, through: :recipe_tags
end

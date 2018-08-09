class RecipeTag < ApplicationRecord
  belongs_to :recipe
  belongs_to :tag

  validates_presence_of :recipe_id
  validates_presence_of :tag_id
end

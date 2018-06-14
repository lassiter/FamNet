class Recipe < ApplicationRecord
  include Interaction
  include Commentable
  
  belongs_to :member

  has_many :recipe_ingredients
  has_many :ingredients, through: :recipe_ingredients
  has_many :recipe_tags
  has_many :tags, through: :recipe_tags

  def mentioned_members
    MentionParser.new(body).members
  end
end

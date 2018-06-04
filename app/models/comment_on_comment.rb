class CommentOnComment < ApplicationRecord
  has_paper_trail
  
  belongs_to :member
  belongs_to :comment
  has_many :interactions, dependent: :destroy
  has_many :likes, through: :interactions
  has_many :hearts, through: :interactions
end

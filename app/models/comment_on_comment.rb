class CommentOnComment < ApplicationRecord
  include Interaction
  has_paper_trail
  
  belongs_to :member
  belongs_to :comment
  has_many :interactions, as: :correlation, dependent: :destroy
end

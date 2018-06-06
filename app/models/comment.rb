class Comment < ApplicationRecord
  include Interaction
  
  has_paper_trail

  belongs_to :commentable, polymorphic: true
  belongs_to :member
  
end

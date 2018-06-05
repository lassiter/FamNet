class Comment < ApplicationRecord
  include Interaction
  has_paper_trail
  
  belongs_to :member
  belongs_to :post
  has_many :commentoncomment, dependent: :destroy
  has_many :interactions, as: :correlation, dependent: :destroy
end

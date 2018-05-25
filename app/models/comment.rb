class Comment < ApplicationRecord
  has_paper_trail
  
  belongs_to :member
  belongs_to :post
  has_many :likes, dependent: :destroy
  
end

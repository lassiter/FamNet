class Interaction < ApplicationRecord
  has_paper_trail

  belongs_to :post
  belongs_to :comment
  belongs_to :member
  has_many :likes
  has_many :hearts

  enum :type_of_interactions => [:heart, :like]

  validates :type_of_interactions, presence: true
  validates :member_id, presence: true

end

class Post < ApplicationRecord
  has_paper_trail

  belongs_to :family
  belongs_to :member
  has_many :comments, dependent: :destroy
  has_many :interactions, dependent: :destroy
  has_many :likes, through: :interactions
  has_many :hearts, through: :interactions

  validates :body, length: { minimum: 1 }
  validates_presence_of :body, :unless => :attachment?

end

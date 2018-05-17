class Family < ApplicationRecord
  has_many :family_members, dependent: :destroy
  has_many :members, through: :family_members
  validates :family_name, presence: true, format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }, length: { minimum: 1 }
end

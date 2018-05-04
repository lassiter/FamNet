class Family < ApplicationRecord
  has_many :family_members
  has_many :members, through: :family_members
  validate :surname, presence: true, format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }, length: { minimum: 1 }

end
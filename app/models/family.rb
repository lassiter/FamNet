class Family < ApplicationRecord
  has_many :family_members
  has_many :members, through: :family_members
end

class Member < ApplicationRecord
  has_many :family_members
  has_many :families, through: :family_members
end

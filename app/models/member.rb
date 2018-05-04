class Member < ApplicationRecord
  has_many :family_members
  has_many :families, through: :family_members

  enum gender: [:female, :male, :nonbinary]

  validate :first_name, presence: true, format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }, length: { minimum: 1 }
  validate :last_name, presence: true, format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }, length: { minimum: 1 }
  # Regex is from http://guides.rubyonrails.org/active_record_validations.html
  validate :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "invalid email format" }, length: { minimum: 1 }
  validate :bio, allow_blank: true, length: { maximum: 500 }
  validate :gender, allow_blank: true, inclusion: { in: gender.keys }
end

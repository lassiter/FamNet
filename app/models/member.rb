class Member < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  devise :database_authenticatable,
        :jwt_authenticatable,
        jwt_revocation_strategy: JWTBlacklist
  has_many :family_members
  has_many :families, through: :family_members

  enum :gender => [:female, :male, :nonbinary]

  validates :first_name, presence: true, format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }, length: { minimum: 1 }
  validates :last_name, presence: true, format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }, length: { minimum: 1 }
  # Regex is from http://guides.rubyonrails.org/active_record_validations.html
  validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "invalid email format" }, length: { minimum: 1 }
  validates :bio, allow_blank: true, length: { maximum: 500 }
  validates :gender, allow_blank: true, inclusion: { in: genders.keys }
end

class Member < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  has_many :family_members, dependent: :destroy
  has_many :families, through: :family_members
  has_many :posts
  has_many :comments
  has_many :likes

  enum :gender => [:female, :male, :nonbinary]
  enum :user_role => [:user, :moderator, :admin, :owner]

  validates :name, presence: true, format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }, length: { minimum: 1 }
  validates :surname, presence: true, format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }, length: { minimum: 1 }
  # Regex is from http://guides.rubyonrails.org/active_record_validations.html
  validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "invalid email format" }, length: { minimum: 1 }
  validates :bio, allow_blank: true, length: { maximum: 500 }
  validates :gender, allow_blank: true, inclusion: { in: genders.keys }
end

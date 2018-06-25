class FamilyMember < ApplicationRecord
  belongs_to :family
  belongs_to :member
  
  enum :user_role => [:user, :moderator, :admin, :owner]

end

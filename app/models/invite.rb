class Invite < ApplicationRecord

  belongs_to :family
  belongs_to :sender, :class_name => 'Member'
  belongs_to :recipient, :class_name => 'Member', optional: true
  
  before_create :generate_token
  before_save :check_user_existence
  after_save :create_family_member,
    unless: Proc.new { |invite| invite.recipient_id.nil? }

  validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "invalid email format" }, length: { minimum: 1 }


  def check_user_existence
      recipient = Member.find_by_email(email)
    if recipient
        self.recipient_id = recipient.id
    end
  end

  def generate_token
    self.token = Digest::SHA1.hexdigest([self.family_id, Time.now, rand].join)
  end  
  
  def create_family_member
    FamilyMember.find_or_create_by(family_id: family_id, member_id: recipient_id)
    # self.token = nil
    # self.accepted_at = DateTime.now
  end

end

class Invite < ApplicationRecord

  belongs_to :family
  belongs_to :sender, :class_name => 'Member'
  belongs_to :recipient, :class_name => 'Member'
  
  before_create :generate_token
  before_save :check_user_existence

  def check_user_existence
      recipient = User.find_by_email(email)
    if recipient
        self.recipient_id = recipient.id
    end
  end

  def generate_token
    self.token = Digest::SHA1.hexdigest([self.family_id, Time.now, rand].join)
  end  

end

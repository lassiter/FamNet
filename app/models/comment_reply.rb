class CommentReply < ApplicationRecord
  include Interaction
  include Notifiable

  has_paper_trail
  belongs_to :comment

  def mentioned_members
    MentionParser.new(body).members
  end
end

class Comment < ApplicationRecord
  include Interaction
  include Notifiable
  
  has_paper_trail

  belongs_to :commentable, polymorphic: true
  belongs_to :member

  has_many :comment_replies
  
  def self.comment_replies
    CommentReply.where(comment_id: ids)
  end

  def mentioned_members
    MentionParser.new(body).members
  end
end

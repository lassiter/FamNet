class CommentReply < ApplicationRecord
  include Interaction

  has_paper_trail
  belongs_to :comment

  def mentioned_members
    MentionParser.new(body).members
  end
end

class CommentReply < ApplicationRecord
  include Interaction

  has_paper_trail
  belongs_to :comment

end

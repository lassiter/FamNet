class Post < ApplicationRecord
  include Interaction
  include Commentable
  include Notifiable
  has_paper_trail

  belongs_to :family
  belongs_to :member

  validates :body, length: { minimum: 1 }
  validates_presence_of :body, :unless => :attachment?

  # has_one_attachment :attachment

  def mentioned_members
    MentionParser.new(body).members
  end
end

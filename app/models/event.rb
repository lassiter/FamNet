class Event < ApplicationRecord
  include Interaction
  include Commentable
  before_create do
    self.event_start = Date.today unless self.event_start
  end
  has_paper_trail
  default_scope { order(event_start: :desc) }

  belongs_to :family
  belongs_to :member
  has_many :event_rsvps
end

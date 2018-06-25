class EventRsvp < ApplicationRecord
  include Notifiable
  has_paper_trail
  belongs_to :member
  belongs_to :event
end

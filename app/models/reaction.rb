class Reaction < ApplicationRecord
  belongs_to :interaction, polymorphic: true
  belongs_to :member
  include Notifiable

  # These are the types of constants that are allowed to have interactions.
  enum :emotive => {heart: 0, like: 1, dislike: 2, haha: 3, wow: 4, sad: 5, angry: 6}
end

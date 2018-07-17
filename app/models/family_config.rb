class FamilyConfig < ApplicationRecord
  attr_readonly :id, :family_id

  belongs_to :family

  validates :family, presence: true

  # validates :authorization_enabled, boolean
end

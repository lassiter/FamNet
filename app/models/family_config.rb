class FamilyConfig < ApplicationRecord
  belongs_to :family

  validates :family, presence: true
  # validates :authorization_enabled, boolean
end

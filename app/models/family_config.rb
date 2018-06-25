class FamilyConfig < ApplicationRecord
  belongs_to :family

  validates :family, presence: true
  validates :authorization_enabled, presence: true
end

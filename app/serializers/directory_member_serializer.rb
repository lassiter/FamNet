class DirectoryMemberSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  type "member"

  attributes :id, :full_name, :nickname, :image, :image_store

  attribute :full_name do
    [object.name, object.surname].join(" ")
  end

  link(:self) { api_v1_member_path(id: object.id) }

  has_many :families, through: :family_members, serializer: FamilySerializer do
    object.families.each do |family|
      link(:related) { api_v1_family_path(id: family.id) }
    end
  end
end
# puts JSON.pretty_generate(DirectoryMemberSerializer.new(m).serializable_hash)
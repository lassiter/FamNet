class FamilyMemberSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  type "family-member"
  attributes :id, :family_id, :member_id, :authorized_at, :user_role, :updated_at, :created_at

  link(:self) { api_v1_family_member_url(object.id) }

  has_one :member, serializer: MemberPreviewSerializer do
    link(:related) { api_v1_member_url(object.member.id) }
  end
  has_one :family, serializer: FamilySerializer do
    link(:related) { api_v1_family_url(object.family.id) }
  end
end

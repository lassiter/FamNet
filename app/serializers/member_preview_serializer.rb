class MemberPreviewSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  type "member"
  attributes :id, :name, :surname, :nickname, :image, :image_store

  attribute :links do
    member_id = object.id
    {
      self: api_v1_member_path(member_id)
    }
  end
end

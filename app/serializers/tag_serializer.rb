class TagSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  type "tag"
  attributes :id, :title, :description, :mature

  link(:self) { api_v1_tag_url(object.id) }

end

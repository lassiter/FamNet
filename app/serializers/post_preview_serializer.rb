class PostPreviewSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  type 'post'
  attributes :id, :family_id, :member_id, :body, :location, :locked, :created_at, :updated_at
  # link :links do
  #   id = object.id
  #   member_id = object.member.id
  #   {
  #     self: api_v1_post_path(id),
  #     comments: api_v1_post_comments_path(id),
  #     member: api_v1_member_path(member_id)
  #   }
  # end
  link(:self) { api_v1_post_path(id: object.id) }
  link(:comments) { api_v1_post_comments_path(object.id) }
  link(:member) { api_v1_member_path(id: object.member.id) }

  has_many :comments, polymorphic: true, serializer: CommentSerializer do
    link(:related) { api_v1_post_comments_path(object.id) }
  end

end

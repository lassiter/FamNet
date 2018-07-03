class CommentSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  type 'comment'

  attributes :id, :body, :edit, :commentable_type, :commentable_id, :member_id, :attachment, :created_at, :updated_at
  attribute :links do
    id = object.id
    member_id = object.member
    {
      self: api_v1_comment_path(id),
      comment_replies: api_v1_comment_comment_replys_path(id),
      member: api_v1_member_path(member_id)
    }
  end
  has_one :commentable
  has_one :member, serializer: MemberPreviewSerializer
  has_many :comment_replies, serializer: CommentReplySerializer
  has_many :reactions, serializer: ReactionPreviewSerializer

end
# puts JSON.pretty_generate(CommentSerializer.new(c).serializable_hash)
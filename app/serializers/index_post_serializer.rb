class IndexPostSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  type 'post'
  attributes :id, :family_id, :member_id, :body, :location, :edit, :attachment, :locked, :created_at, :updated_at

  attribute :links do
    id = object.id
    member_id = object.member
    {
      self: api_v1_post_path(id),
      comments: api_v1_post_comments_path(id),
      member: api_v1_member_path(member_id)
    }
  end
  has_one :member
  has_many :comments, serializer: CommentPreviewSerializer do
    link(:related) { api_v1_post_comments_path(object.id, commentable_type: "Post", commentable_id: object.id) }

    comments = object.comments
    # The following code is needed to avoid n+1 queries.
    # Core devs are working to remove this necessity.
    # See: https://github.com/rails-api/active_model_serializers/issues/1325
    comments.loaded? ? microposts : comments.none
  end
  has_many :reactions, serializer: ReactionPreviewSerializer

end

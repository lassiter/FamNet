class CommentPreviewSerializer < ActiveModel::Serializer
  type "comment"
  attributes :id, :body, :member_id
end

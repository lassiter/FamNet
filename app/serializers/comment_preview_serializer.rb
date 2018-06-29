class CommentPreviewSerializer < ActiveModel::Serializer
  attributes :id, :body, :member_id
end

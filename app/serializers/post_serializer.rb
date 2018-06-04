class PostSerializer < ActiveModel::Serializer
  attributes :id, :family_id, :member_id, :body, :location, :edit, :attachment, :locked, :created_at, :updated_at
end

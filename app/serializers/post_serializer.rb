class PostSerializer < ActiveModel::Serializer
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
  has_many :comments, serializer: CommentSerializer, polymorphic: true
  has_many :reactions, serializer: ReactionPreviewSerializer
  def comments
    object.comments.map do |c|

end
# puts JSON.pretty_generate(PostSerializer.new(p).serializable_hash)
    # reactions = object.reactions
    # reactions.loaded? ? reactions : reactions.none
    
    # @the_count = {}
    # Reaction.emotives.map do |key, value|
    #   value = reactions.where(emotive: key).count
    #   @the_count.merge!({key => value})
    # end
    # {
    #   @the_count
    # }

  # "reaction_counts": {
  #   "count": {
  #     "heart": 1,
  #     "like": 1,
  #     "dislike": 0,
  #     "haha": 0,
  #     "wow": 0,
  #     "sad": 0,
  #     "angry": 0
  #   }
  # },
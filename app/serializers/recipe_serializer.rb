class RecipeSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  type "recipe"
  attributes :id, :title, :description, :steps, :attachment, :ingredients_list, :tags_list, :member_id, :created_at, :updated_at

  link(:self) { api_v1_recipes_url(id: object.id) }

  has_one :member, serializer: MemberPreviewSerializer do
    link(:related) { api_v1_member_url(object.member_id) }
  end

  has_many :tags, serializer: TagSerializer
  has_many :ingredients, serializer: IngredientSerializer

end

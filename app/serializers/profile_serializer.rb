class ProfileSerializer < ActiveModel::Serializer
  type "member"
  attributes :id, :name, :nickname, :image, :email, :created_at, :updated_at, :surname, :image_store, :contacts, :addresses, :gender, :bio, :birthday, :instagram

  def attributes(*args) # Processes each attribute allowing for easier management of attribute hashes.
    hash = super
    # User Data for Account Management
    unless object.id == current_user.id || current_user.family_members.exists?(user_role: "admin", family_id: object.family_ids)
      hash.merge(:provider => object[:provider])
      hash.merge(:uid => object[:uid])
      hash.merge(:allow_password_change => object[:allow_password_change])
    end
    hash
  end

  link(:self) { api_v1_member_path(id: object.id) }

  has_many :families, through: :family_members, serializer: FamilySerializer do
    object.families.each do |family|
      link(:related) { api_v1_family_path(id: family.id) }
    end
  end
  has_many :event_rsvps, through: :events, serializer: EventRsvpPreviewSerializer do
    object.event_rsvps.each do |rsvp|
      link(:event) { api_v1_event_path(id: rsvp.event_id) }
    end
  end
  has_many :family_members, serializer: FamilyMemberSerializer
  has_many :posts, serializer: PostPreviewSerializer do
    object.posts.each do |post|
      link(:related) { api_v1_post_path(id: post.id) }
    end
  end
  has_many :recipes, serializer: RecipePreviewSerializer do
    object.recipes.each do |recipe|
      link(:related) { api_v1_recipe_path(id: recipe.id) }
    end
  end
end

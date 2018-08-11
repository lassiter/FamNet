class EventRsvpSerializer < ActiveModel::Serializer
  attributes :id, :party_size, :rsvp, :bringing_food, :recipe_id, :non_recipe_description, :serving, :member_id, :party_companions, :event_id, :rsvp_note, :created_at, :updated_at

  belongs_to :event, serializer: EventSerializer do
    link(:related) { api_v1_events_rsvps_path(object.id) }
  end
end

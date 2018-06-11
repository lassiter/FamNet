class API::V1::EventsRsvpsController < ApplicationController

  def create
    @event_rsvp = EventRsvp.new(event_rsvp_params)

    unless EventRsvp.any?(event_id: params[:event_rsvp][:event_id], member_id: params[:event_rsvp][:member_id])
      if @event_rsvp.save
        render json: @event_rsvp
      else
        render json: { errors: @event_rsvp.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: {{ errors: "Duplicate RSVP Found"} =>  @event_rsvp }, status: :conflict
    end
  end

  def destroy
    begin
      @event_rsvp = EventRsvp.find(params[:id])
      @event_rsvp.destroy
      render json: {}, status: :no_content
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end
  end

  private
  def event_rsvp_params
    params.require(:event_rsvp).permit(:id, :party_size, :rsvp, :bringing_food, :recipe_id, :non_recipe_description, :serving, :member_id, :party_companions, :event_id, :rsvp_note, :created_at, :updated_at)
  end

end

class API::V1::EventsController < ApplicationController
  before_action :authenticate_api_v1_member!
  def index
    begin
      unless params[:filter].present? && params[:filter][:scope] == "all"
        @events = policy_scope(Event).all
        render json: @events, each_serializer: EventSerializer, adapter: :json_api
      else
        begin
          @events = Event.where("event_start > ?", Date.today)
          # @events = policy_scope(Event.where("event_start > ?", Date.today))
          render json: @events
        rescue Pundit::NotDefinedError # mentor
          render json: {}, status: :no_content
        end
      end
    end
  end

  def show
    begin
      @event = Event.find(params[:id])
      if @event.event_rsvps.any?
        render json: @event, serializer: EventSerializer, include: [:'event_rsvps'], adapter: :json_api, status: :ok
      else
        render json: @event, serializer: EventSerializer, adapter: :json_api
      end
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end
  end

  def create
    @event = EventFactory.new(event_params).result
    if @event.save
      @event_rsvp = EventFactory.new(@event).event_creator_rsvp.save
      render json: @event, serializer: EventSerializer, include: [:'event_rsvps'], adapter: :json_api, status: :ok
    else
      puts @event.errors.full_messages
      render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @event = Event.find(params[:id])
    @event.assign_attributes(event_params)

    if @event.save
      render json: @event
    else
      render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
    end
  end

   def destroy
    begin
      @event = Event.find(params[:id])
      @event.destroy
      render json: {}, status: :no_content
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end
   end

  private
    def event_params
      params.require(:event).permit(:id, :attributes => [:title,:description, :event_start, :event_end, :event_allday, :location, :attachment, :locked, :potluck, :family_id, :member_id])
    end

end

class API::V1::EventsController < ApplicationController
  # before_action :authenticate_api_v1_member!
  def index
    if params[:filter][:scope] == "all"
      @events = Event.all
      # @events = policy_scope(Event)
      render json: @events
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
  
  def show
    begin
      @event = Event.find(params[:id])
      if @event.event_rsvps.any?
        render json: {"event" => @event, "event_rsvps"=> @event.event_rsvps}, status: :ok
      else
        render json: @event, status: :ok
      end
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      render json: @event
    else
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
      params.require(:event).permit(:id, :title,:description, :event_start, :event_end, :event_allday, :location, :attachment, :locked, :potluck, :family_id, :member_id)
    end

end

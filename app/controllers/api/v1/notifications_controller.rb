class API::V1::NotificationsController < ApplicationController

  def index
    @notifications = Notification.all.where(member_id: current_user.id)
  end

  def create
    @notification = Notification.new(notification_params)
    if @notification.save
      render json: @notification
    else
      render json: { errors: @notification.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @notification = Notification.find(id: params[:id])
    @notification.assign_attributes(notification_params)

    if @notification.save
      render json: @notification
    else
      render json: { errors: @notification.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @notification = Notification.find(params[:id])
      @notification.destroy
      render json: {}, status: :no_content
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end
  end
  private
  def notification_params
    params.require(:notification).permit(:id, :notifiable_type, :notifiable_id, :member_id, :mentioned, :viewed)
  end

end

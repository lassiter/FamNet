class API::V1::InteractionController < ApplicationController

  def initialize(interaction_params)
    
  end

  def index
    @interactions = Interaction.where(comment_id: params[:comment_id])
    render json: @interactions
  end
  def show
    @interaction = Interaction.find(params[:id])
    render json: @interaction
  end
  def create
    @interaction = Interaction.new(comment_params)
    
    if @interaction.save
      render json: @interaction
    else
      render json: { errors: @interaction.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @interaction = Interaction.find(params[:id])
    @interaction.assign_attributes(comment_params)

    if @interaction.save
      render json: @interaction
    else
      render json: { errors: @interaction.errors.full_messages }, status: :unprocessable_entity
    end
  end

   def destroy
    begin
      @interaction = Interaction.find(params[:comment][:id])
      @interaction.destroy
      render json: {}, status: :no_content
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end
   end

  private
    def interaction_params
      params.require(:interaction).permit(:interaction_type, :comment_on_comment_id, :comment_id, :post_id, :member_id)
    end
end

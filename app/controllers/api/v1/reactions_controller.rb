class API::V1::ReactionsController < ApplicationController

  # before_action :authenticate_api_v1_member!
  before_action :load_interactions
  skip_before_action :load_interactions, only: [:create, :destroy]
  def index
    @reactions = @interaction.reactions
    render json: @reactions
  end
  
  def create
    @reaction = Reaction.new(reaction_params)

    if @reaction.save
      render json: @reaction
    else
      render json: { errors: @reaction.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @reaction = Reaction.find(params[:id])
      @reaction.destroy
      render json: {}, status: :no_content
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end
  end

  private
  
  def load_interactions
    klass = [Post, Comment, CommentReply, Recipe].detect { |i| params["#{i.name.underscore}_id"]}
    @interaction = klass.find(params["#{klass.name.underscore}_id"])
  end

  def reaction_params
    params.require(:reaction).permit(:id, :member_id, :emotive, :interaction_type, :interaction_id)
  end

end

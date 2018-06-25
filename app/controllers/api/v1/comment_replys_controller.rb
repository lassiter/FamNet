class API::V1::CommentReplysController < ApplicationController
  
  def index
    @commentreplys = CommentReply.where(comment_id: params[:comment_id])
    render json: @commentreplys
  end
  
  def show
    @commentreply = CommentReply.find(params[:id])
    render json: @commentreply
  end

  def create
    @commentreply = CommentReply.new(comment_reply_params)

    if @commentreply.save
      render json: @commentreply
    else
      render json: { errors: @commentreply.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @commentreply = CommentReply.find(params[:id])
    @commentreply.assign_attributes(comment_reply_params)

    if @commentreply.save
      render json: @commentreply
    else
      render json: { errors: @commentreply.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @commentreply = CommentReply.find(params[:id])
      @commentreply.destroy
      render json: {}, status: :no_content
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end
  end

  private
    def comment_reply_params
      params.require(:comment_reply).permit(:id, :body, :attachment, :member_id, :comment_id)
    end
end
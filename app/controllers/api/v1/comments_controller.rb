class API::V1::CommentsController < ApplicationController
  def index
    @comments = Comment.where(post_id: params[:post_id])
    render json: @comments
  end
  def show
    @comment = Comment.find(params[:id])
    render json: @comment
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      # @notification = Notification.new(notifiable_type: "Comment", notifiable_id: @comment.id, member_id: comment_params[:member_id].to_i)
      # if @notification.save
      render json: @comment
      # else
      #   render json: {comment: @comment, errors: @notification.errors.full_messages }
      # end
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @comment = Comment.find(params[:id])
    @comment.assign_attributes(comment_params)

    if @comment.save
      render json: @comment
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

   def destroy
    begin
      @comment = Comment.find(params[:comment][:id])
      @comment.destroy
      render json: {}, status: :no_content
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end
   end

  private
    def comment_params
      params.require(:comment).permit(:body, :attachment, :member_id, :commentable_id, :commentable_type)
    end
end

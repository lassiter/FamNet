# CommentOnComment is a child of Comment, which is a child of Post.
# CommentOnComment(s) = @childcomment(s)
class API::V1::CommentOnCommentsController < ApplicationController
  def index
    @childcomments = Comment.where(comment_id: params[:comment_id])
    render json: @childcomments
  end
  def show
    @childcomment = Comment.find(params[:id])
    render json: @childcomment
  end

  def create
    @childcomment = Comment.new(comment_params)

    if @childcomment.save
      render json: @childcomment
    else
      render json: { errors: @childcomment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @childcomment = Comment.find(params[:id])
    @childcomment.assign_attributes(comment_params)

    if @childcomment.save
      render json: @childcomment
    else
      render json: { errors: @childcomment.errors.full_messages }, status: :unprocessable_entity
    end
  end

   def destroy
    begin
      @childcomment = Comment.find(params[:comment][:id])
      @childcomment.destroy
      render json: {}, status: :no_content
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end
   end

  private
    def childcomment_params
      params.require(:childcomment).permit(:body, :attachment, :member_id, :comment_id)
    end
end

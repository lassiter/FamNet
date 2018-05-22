class API::V1::PostsController < ApplicationController
  def index
    @posts = Post.all
    render json: @posts
  end
  def show
    @post = Post.find(params[:id])
    render json: @post
  end

  def create
    @post = Post.new(post_params)
    puts params

    if @post.save
      render json: @post
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @post = Post.find(params[:id])
    @post.assign_attributes(post_params)

    if @post.save
      render json: @post
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

   def destroy
    begin
      @post = Post.find(params[:id])
      @post.destroy
      render json: {}, status: :no_content
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end
   end

  private
    def post_params
      params.require(:post).permit(:body, :location, :attachment, :locked, :family_id, :member_id)
    end
end

class API::V1::PostsController < ApplicationController
  before_action :authenticate_api_v1_member!
  def index
    @posts = policy_scope(Post) || []
    render json: @posts, each_serializer: IndexPostSerializer, adapter: :json_api
  end
  def show
    @post = policy_scope(Post).find(params[:id])
    render json: @post, serializer: PostSerializer, adapter: :json_api
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      render json: @post
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    begin
      @post = policy_scope(Post).find(params[:id])
      # binding.pry
      authorize @post
      @post.assign_attributes(post_params)
      if @post.save
        render json: @post
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    rescue Pundit::NotAuthorizedError
      @post.errors.add(:id, :forbidden, message: "current user is not authorized to update this post")
      render :json => { errors: @post.errors.full_messages }, :status => :forbidden
    end
  end

   def destroy
    begin
      begin
      @post = policy_scope(Post).find(params[:id])
      authorize @post
      @post.destroy
      render :json => {}, status: :no_content
      rescue Pundit::NotAuthorizedError
        @post.errors.add(:id, :forbidden, message: "current user is not authorized to delete this post")
        render :json => { errors: @post.errors.full_messages }, :status => :forbidden
      end
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end
   end

  private
    def post_params
      params.require(:post).permit(:attributes => [:body, { :location => [] }, :attachment, :locked, :family_id, :member_id])
    end
end

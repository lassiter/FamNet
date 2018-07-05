class API::V1::PostsController < ApplicationController
  before_action :authenticate_api_v1_member!
  def index
    @posts = policy_scope(Post) || []
    render json: @posts, each_serializer: IndexPostSerializer, adapter: :json_api
  end
  def show
    begin
      @post = policy_scope(Post).find(params[:id])

      render json: @post, 
        include: ['comments', 'reactions', 'member'],
        serializer: PostSerializer, adapter: :json_api
    rescue ActiveRecord::RecordNotFound
      # Workaround for how Pundit scopes policies to allow unauthorized non-family users to have a helpful error message.
      if !current_user.family_members.where.not(authorized_at: nil).pluck(:family_id).include?(Post.find(params[:id]).family_id)
        @post = Post.find(params[:id]) if @post == nil
        @post.errors.add(:id, :forbidden, message: "current user is not authorized to view this post")
        render :json => { errors: @post.errors.full_messages }, :status => :forbidden
      else
        render :json => {}, :status => :not_found
      end
    end
  end

  def create
    begin
      @post = Post.new(post_params)
      authorize @post
      if @post.save
        render json: @post
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    rescue Pundit::NotAuthorizedError
      @post.errors.add(:id, :forbidden, message: "current user is not authorized to create this post in family id: #{@post.family_id}")
      render :json => { errors: @post.errors.full_messages }, :status => :forbidden
    end
  end

  def update
    begin
      begin
        @post = policy_scope(Post).find(params[:id])
        authorize @post
        @post.assign_attributes(update_params)
        if @post.save
          render json: @post
        else
          render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
        end
      rescue Pundit::NotAuthorizedError
        @post.errors.add(:id, :forbidden, message: "current user is not authorized to update this post")
        render :json => { errors: @post.errors.full_messages }, :status => :forbidden
      end
    rescue ActiveRecord::RecordNotFound
      # Workaround for how Pundit scopes policies to allow unauthorized non-family users to have a helpful error message.
      if !current_user.family_members.where.not(authorized_at: nil).pluck(:family_id).include?(Post.find(params[:id]).family_id)
        @post = Post.find(params[:id]) if @post == nil
        @post.errors.add(:id, :forbidden, message: "current user is not authorized to update this post in family id: #{@post.family_id}")
        render :json => { errors: @post.errors.full_messages }, :status => :forbidden
      else
        render :json => {}, :status => :not_found
      end
    end
  end

  def destroy
    begin
      @post = policy_scope(Post).find(params[:id])
      authorize @post
      @post.destroy
      render :json => {}, status: :no_content
    rescue ActiveRecord::RecordNotFound
      # Workaround for how Pundit scopes policies.
      begin
        # "Post API :: Members / Unauthorized to Family :: GET /posts Posts#destroy returns 403 error for an unauthorized attempt to delete"
        unless current_user.family_members.where.not(authorized_at: nil).pluck(:family_id).include?(Post.find(params[:id]).family_id)
          @post = Post.find(params[:id]) if @post == nil
          @post.errors.add(:id, :forbidden, message: "current user is not authorized to delete this post in family id: #{@post.family_id}")
          render :json => { errors: @post.errors.full_messages }, :status => :forbidden
        else
          render :json => {}, :status => :not_found
        end
      rescue ActiveRecord::RecordNotFound # "Post API :: Members / Same Family :: DELETE /posts/:id Posts#destroy returns 404 for missing content"
        render :json => {}, :status => :not_found
      end
    rescue Pundit::NotAuthorizedError # "Post API :: Members / Same Family :: Unauthorize Inside Family :: DELETE /posts Posts#delete :: Member 2 => Member 1 unable to delete on another family member's post"
      @post = Post.find(params[:id]) if @post == nil
      @post.errors.add(:id, :forbidden, message: "current user is not authorized to delete this post in family id: #{@post.family_id}")
      render :json => { errors: @post.errors.full_messages }, :status => :forbidden
    end
  end

  private
    def post_params
      params.require(:post).permit(:id, :attributes => [:body, { :location => [] }, :attachment, :locked, :family_id, :member_id])
    end
    def update_params
      params.require(:post).permit(:id, :attributes => [:body, { :location => [] }, :attachment, :locked])
    end
end

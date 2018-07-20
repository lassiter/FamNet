class API::V1::RecipesController < ApplicationController
  def index
    @recipes = policy_scope(Recipe)
    render json: @recipes, each_serializer: RecipeSerializer, adapter: :json_api
  end
  def search
    begin
      query = search_params[:query]
      type = search_params[:type]
      # Searching and Processing Query based on Type
      if type == "tag"
        tag_ids = Tag.where("lower(title) LIKE :search OR lower(description) LIKE :search", search: "%#{query.downcase}%").pluck(:id).uniq
        @recipes = policy_scope(Recipe).where(id: RecipeTag.where(tag_id: tag_ids).pluck(:recipe_id).uniq )
      elsif type == "ingredient"
        ingredient_ids = Ingredient.where("lower(title) LIKE :search", search: "%#{query.downcase}%").pluck(:id).uniq
        @recipes = policy_scope(Recipe).where(id: RecipeIngredient.where(ingredient_id: ingredient_ids).pluck(:recipe_id).uniq )
      elsif type == "recipe"
        @recipes = policy_scope(Recipe).where("lower(title) LIKE :search OR lower(description) LIKE :search", search: "%#{query.downcase}%").uniq
      else
        # Request didn't match any preset types.
        render json: {:query => query, :type => type, :message => "Request type likely didn't match 'tag', 'ingredient, or 'recipe'."}, status: :bad_request
        return
      end
      # Formatting for Render
      if @recipes == [] || @recipes.nil?
        render json: {}, status: :no_content
      else
        render json: @recipes, each_serializer: RecipeSerializer, adapter: :json_api
      end
    rescue Pundit::NotAuthorizedError
      @recipes.errors.add(:id, :forbidden, message: "current user is not authorized to search this post in family id: #{@recipes.family_id}")
      render :json => { errors: @recipes.errors.full_messages }, :status => :forbidden
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end #rescue
  end
  def show
    begin
      @recipe = Recipe.find(params[:id])
      render json: @recipe, serializer: RecipeSerializer, adapter: :json_api
    rescue Pundit::NotAuthorizedError
      @recipe.errors.add(:id, :forbidden, message: "current user is not authorized to search this post in family id: #{@recipe.family_id}")
      render :json => { errors: @recipe.errors.full_messages }, :status => :forbidden
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end
  end

  def create
    begin
      # pre authorize?
      @recipe = API::V1::RecipeFactoryController.new(recipe_params).result
      
      if @recipe.save
        # @recipe.factory_callback(@recipe.id)
        render json: @recipe, serializer: RecipeSerializer, adapter: :json_api
      else
        render json: { errors: @recipe.errors.full_messages }, status: :unprocessable_entity
      end
    rescue Pundit::NotAuthorizedError
      @recipe.errors.add(:id, :forbidden, message: "current user is not authorized to search this post in family id: #{@recipe.family_id}")
      render :json => { errors: @recipe.errors.full_messages }, :status => :forbidden
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end
  end

  def update
    @recipe = Recipe.find(params[:id])
    @recipe.assign_attributes(recipe_params)

    if @recipe.save
      render json: @recipe
    else
      render json: { errors: @recipe.errors.full_messages }, status: :unprocessable_entity
    end
  end

   def destroy
    begin
      @recipe = Recipe.find(params[:id])
      @recipe.destroy
      render json: {}, status: :no_content
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end
   end

  private
    def recipe_params
      params[:recipe][:ingredients_list] ||= []
      params.require(:recipe).permit(
        :title, 
        :description, 
        :member_id, 
        :ingredients_list => [],
        tags_list: [:title, :description, :mature],
        steps:{
          preparation: [:instruction, :time_length, {:ingredients => []}],
          cooking: [:instruction, :time_length, {:ingredients => []}],
          post_cooking: [:instruction, :time_length, {:ingredients => []}]
        })
    end
    def search_params
      params.require(:filter).permit(:query, :type)
    end
    def next_available_id
      if Recipe.count == 0
        id = 1
      else
        id = Recipe.maximum(:id).next
      end
    end
end

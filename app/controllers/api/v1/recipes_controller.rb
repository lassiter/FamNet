class API::V1::RecipesController < ApplicationController
  def index
    @recipes = policy_scope(Recipe)
    render json: @recipes
  end
  def search
    query = params
  end
  def show
    @recipe = Recipe.find(params[:id])
    render json: @recipe
  end

  def create
    puts recipe_params
    @recipe = API::V1::RecipeFactoryController.new(recipe_params).result.factory_callback(@recipe.id)
    

    if @recipe.save
      render json: @recipe
    else
      render json: { errors: @recipe.errors.full_messages }, status: :unprocessable_entity
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
      # Example Expected Params
      # {
      #   title: "some recipe string",
      #   body: "some recipe description text",
      #   member_id: 1,
      #   ingredients: [item1, item2, item3], 
      #   steps: {
      #     preparation: [
      #       {instruction: "task item", ingredients:[item1, item2], time_length: null}
      #     ],
      #     cooking: [
      #       {instruction: "task item", ingredients:[item3], time_length: "1 minute"}
      #     ],
      #     post_cooking: [
      #       {instruction: "task item", ingredients:[item1, item2], time_length: "2 hours"}
      #     ]
      #   }, 
      #   tags: ["tag1", :tag2 => {title: "foo", description: "bar", mature: true}, tag3]
      # }
      params.require(:recipe).permit(
        :title, 
        :description, 
        :member_id, 
        ingredients: [], 
        steps:{
          preparation: [:instruction, :ingredients, :time_length],
          cooking: [:instruction, :ingredients,:time_length],
          post_cooking: [:instruction, :ingredients, :time_length]
        }, 
        tags: [:title, :description, :mature]
        
        )
    end
    def next_available_id
      if Recipe.count == 0
        id = 1
      else
        id = Recipe.maximum(:id).next
      end
    end
end

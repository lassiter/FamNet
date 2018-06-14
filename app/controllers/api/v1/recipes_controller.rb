class API::V1::RecipesController < ApplicationController
  def index
    @recipes = policy_scope(Recipe)
    render json: @recipes
  end
  def search
    # @recipes = policy_scope(Recipe)
    query = params[:query]
    type = params[:type]
    # Searching and Processing Query based on Type
    if :type == "tag"
      result = Recipe.where(id: RecipeTag.where(tag_id: Tag.where("title LIKE ? ", "%#{:query.downcase}%").pluck(:id)).or(tag_id: Tag.where("description LIKE ? ", "%#{:query.downcase}%").pluck(:id)).pluck(:recipe_id))
      # SELECT 
      #   recipes.*
      # FROM recipes INNER JOIN recipe_tags ON recipes.ID = recipe_tags.recipe_id INNER JOIN tags ON recipe_tags.tag_id = tags.id
      #   WHERE LOWER(tags.title) LIKE LOWER('%foo%') OR LOWER(tags.description) LIKE LOWER('%foo%');
    elsif :type == "ingredient"
      # result = Recipe.where(id: RecipeIngredient.where(ingredient_id: Ingredient.where("title LIKE ? ", "%#{:query.downcase}%").pluck(:id)).pluck(:recipe_id))
      result = Recipe.find_by_sql("SELECT recipes.* FROM recipes INNER JOIN recipe_ingredients ON recipes.ID = recipe_ingredients.recipe_id INNER JOIN ingredients ON recipe_ingredients.ingredient_id = ingredients.id WHERE (ingredients.title LIKE '%#{:query.downcase}%');")
    elsif :type == "recipe"
      result = Recipe.where("title LIKE ? ", "%#{:query.downcase}%").or(Recipe.where("description LIKE ? ", "%#{:query.downcase}%"))
    else
      # Mentor, How to do a bucket search?
      result = Recipe.where()
    end
    # Formatting for Render
    if result.nil?
      
    else
      
    end
  end
  def show
    @recipe = Recipe.find(params[:id])
    render json: @recipe
  end

  def create
    @recipe = API::V1::RecipeFactoryController.new(recipe_params).result
    
    if @recipe.save
      # @recipe.factory_callback(@recipe.id)
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
    def next_available_id
      if Recipe.count == 0
        id = 1
      else
        id = Recipe.maximum(:id).next
      end
    end
end

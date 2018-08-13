class RecipeFactory
  def initialize(recipe_params)
    recipe_params = recipe_params.to_h
    @title = recipe_params["title"].to_s

    @description = recipe_params["description"].to_s
    
    @ingredients_object_array = []
    @ingredients = recipe_params["ingredients_list"].to_a.each do |ingredient|
      i = Ingredient.find_or_create_by(title: ingredient)

      @ingredients_object_array << i
    end
    
    @tags_object_array = []
    @tags = recipe_params["tags_list"].each do |tag|   
      t = tag
      tag = Tag.find_or_create_by(title: tag["title"].titleize)
      if tag.description == nil
        tag.update_attributes(description: t["description"])
      end
      if t["mature"].present? && ActiveModel::Type::Boolean.new.cast(t["mature"]) == true
        tag.update_attributes(mature: ActiveModel::Type::Boolean.new.cast(t["mature"]))
      end
      @tags_object_array << tag
    end

    @steps = recipe_params["steps"] # json

    @member = Member.find(recipe_params["member_id"].to_i) # object

  end
  
  def result
    Recipe.new({
      title: @title, # string
      description: @description, # text
      member_id: @member.id,
      steps: @steps.to_h,
      attachment: nil,
      ingredients_list: @ingredients_object_array.map {|ingredient| ingredient.title},
      tags_list: @tags_object_array.map {|tag| tag.title}
    })
  end

  def factory_callback(id)
    joins = []
    @tags_object_array.each do |tag|
      joins << RecipeTag.create(tag_id: tag.id, recipe_id: id)
    end

    @ingredients_object_array.each do |ingredient|
      joins << RecipeIngredient.create(ingredient_id: ingredient.id, recipe_id: id)
    end
    return joins
  end

end
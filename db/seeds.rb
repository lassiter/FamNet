# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
  5.times do
    Family.create(
      family_name: Faker::Name.last_name
    )
  end
  50.times do

    new_member = Member.create(
      name: Faker::Name.first_name,
      surname: Faker::Name.last_name,
      nickname: Faker::RickAndMorty.character,
      birthday: Faker::Date.birthday(13, 65),
      gender: rand(0..2),
      email: Faker::Internet.email,
      password: "password",
      image: "https://www.us.fakers.s3.amazon.com/#{Faker::Internet.password(10, 20)}/#{Faker::Internet.domain_word}.jpg",
      contacts: {

      },
      addresses: {
        "home" => {
          "street_address" => Faker::Address.street_address,
          "secondary_address" => [nil, Faker::Address.secondary_address].sample,
          "city" => Faker::Address.city,
          "state" => Faker::Address.state_abbr,
          "zip" => Faker::Address.zip_code,
          "country" => "USA"
        }
      },
      instagram: Faker::Internet.domain_word
    )
    FamilyMember.create(
      family_id: rand(1..Family.count),
      member_id: new_member.id
    )  
  end
  member_size = Member.count
  100.times do
    @member = FamilyMember.where(member_id: rand(1..member_size)).first
    @post = Post.create(
      body: Faker::Lorem.paragraph(2, false, 4),
      location: [Faker::Address.latitude, Faker::Address.longitude],
      family_id: @member.family_id,
      member_id: @member.member_id
    )
    rand(0..14).times do
      Interaction.create(
        member_id: FamilyMember.where(family_id: @member.family_id).order("RANDOM()").first.member_id,
        interaction_type: "Post",
        interaction_id: @post.id,
        emotive: [:heart, :like].sample
      )
    end
    rand(1..5).times do
      @commenter = FamilyMember.where(family_id: @member.family_id).order("RANDOM()").first
      comment = Comment.create(
        member_id: @commenter.member_id,
        post_id: @post.id,
        body: Faker::Lorem.paragraph(1, false, 2),
      )
      rand(0..3).times do
        Interaction.create(
          member_id: FamilyMember.where(family_id: @member.family_id).order("RANDOM()").first.member_id,
          interaction_type: "Comment",
          interaction_id: comment.id,
          emotive: [:heart, :like].sample
        )
      end
    end

  end
25.times do

  @recipe_hash = 
  {
    "ingredients_list": [],
    "tags_list": [],
    "steps": {
      "preparation": [],
      "cooking": [],
      "post_cooking": []
    }
  }
  @recipe_hash[:steps].each_key do |key|
    rand(1..5).times do
      hash = {"instruction": "#{Faker::Lorem.sentence(5, true, 5)}", "ingredients": Array.new(rand(3..10)) { Ingredient.find_or_create_by(title:Faker::Food.ingredient) }, "time_length": "#{rand(1..59).minutes}"}
      @recipe_hash[:steps][key] << hash
      @recipe_hash[:ingredients_list] = @recipe_hash[:ingredients_list] | hash[:ingredients]
    end
  end
  @recipe_hash[:tags_list] = Array.new(rand(3..9)) { Tag.find_or_create_by(title: Faker::Vehicle.manufacture) }
  @recipe_hash[:tags_list].each {|item| item.update(description: Faker::RickAndMorty.quote, mature: [true,false].sample)}
  @recipe = Recipe.create({
    title: Faker::Food.dish,
    description: Faker::Lorem.sentence(5, true, 5),
    member_id: rand(1..member_size),
    steps: @recipe_hash[:steps].to_h,
    attachment: Faker::File.file_name('s3/img', Faker::Internet.domain_word, ['gif','jpg','png'].sample),
    ingredients_list: @recipe_hash[:ingredients_list].map {|ingredient| ingredient.title},
    tags_list: @recipe_hash[:tags_list].map {|tag| tag.title},
    ingredients: @recipe_hash[:ingredients_list],
    tags: @recipe_hash[:tags_list] 
    })
  end


puts "Recipes: #{Recipe.count} out of 25 were created using a total of #{Ingredient.count} Ingredients and #{Tag.count} Tags."
puts "Sucessfully linked #{RecipeIngredient.count} Recipe Ingredients and #{RecipeTag.count} Recipe Tags."
puts "Posts: #{Post.count} out of 100 were created."
puts "Comments: #{Comment.count} were created."
puts "Families: #{Family.count} out of 5 were created."
puts "Family Member Links: #{FamilyMember.count} out of 50 were created."
puts "Members: #{Member.count} out of 50 were created."
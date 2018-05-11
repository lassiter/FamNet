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

puts "Families: #{Family.count} out of 5 were created."
puts "Family Member Links: #{FamilyMember.count} out of 50 were created."
puts "Members: #{Member.count} out of 50 were created."
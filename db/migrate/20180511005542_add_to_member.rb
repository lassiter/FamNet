class AddToMember < ActiveRecord::Migration[5.2]
  def change
    change_table :members do |t|
      ## User Info
      t.integer :user_role, default: 0
      t.string :surname
      t.binary :image_store
      t.json :contacts, default: "{}"
      t.json :addresses, default: "{}"
      t.integer :gender
      t.text :bio
      t.date :birthday
      ## Social Media
      t.string :instagram

    end
  end
end

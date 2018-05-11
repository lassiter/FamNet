class AddToMember < ActiveRecord::Migration[5.2]
  def change
    change_table :members do |t|
      ## User Info
      t.integer :user_role, default: 0
      # t.string :name      via devise_token_auth
      t.string :surname
      # t.string :nickname  via devise_token_auth
      # t.string :image     via devise_token_auth
      t.binary :image_store
      # t.string :email     via devise_token_auth
      t.text :contacts, default: "{}"
      t.text :addresses, default: "{}"
      t.integer :gender
      t.text :bio
      t.date :birthday
      ## Social Media
      t.string :instagram

    end
  end
end

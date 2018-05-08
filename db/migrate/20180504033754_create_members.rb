class CreateMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :members do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.text :contacts, default: "{}"
      t.text :addresses, default: "{}"
      t.integer :gender
      t.text :bio
      t.timestamps
    end
  end
end

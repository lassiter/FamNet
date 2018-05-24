class CreateRecipes < ActiveRecord::Migration[5.2]
  def change
    create_table :recipes do |t|
      t.string :title, :null => false
      t.text :description
      t.binary :attachment
      t.refrences :family_id
      t.refrences :member_id 
      t.timestamps
    end
  end
end

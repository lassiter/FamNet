class CreateRecipes < ActiveRecord::Migration[5.2]
  def change
    create_table :recipes do |t|
      t.string :title, :null => false
      t.text :description
      t.json :steps
      t.binary :attachment
      t.text :ingredients, array: true
      t.text :tags, array: true
      t.references :family
      t.references :member
      t.timestamps
    end
  end
end

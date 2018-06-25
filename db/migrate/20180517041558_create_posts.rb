class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.text :body, :null => false
      t.decimal :location, array: true, precision: 15, scale: 10
      t.text :edit
      t.binary :attachment
      t.boolean :locked, default: false
      t.references :family
      t.references :member
      t.timestamps
    end
  end
end

class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.text :body, :null => false
      t.text :edit
      t.references :commentable
      t.integer :member_id
      t.binary :attachment
      t.timestamps
    end
  end
end

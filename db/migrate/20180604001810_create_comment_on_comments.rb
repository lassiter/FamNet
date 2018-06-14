class CreateCommentOnComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comment_on_comments do |t|
      t.text :body, :null => false
      t.text :edit
      t.integer :comment_id
      t.integer :member_id
      t.binary :attachment
      t.timestamps
      t.timestamps
    end
  end
end

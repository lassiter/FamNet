class CreateInteractions < ActiveRecord::Migration[5.2]
  def change
    create_table :interactions do |t|
      t.string :type_of_interactions
      t.references :comment_id
      t.references :post_id
      t.integer :member_id, null: false
      t.timestamps
    end
  end
end

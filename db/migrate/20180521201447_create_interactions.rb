class CreateInteractions < ActiveRecord::Migration[5.2]
  def change
    create_table :interactions do |t|
      t.string :type_of_interactions
      t.refrences :comment_id
      t.refrences :post_id
      t.integer :member_id, null: false
      t.timestamps
    end
  end
end

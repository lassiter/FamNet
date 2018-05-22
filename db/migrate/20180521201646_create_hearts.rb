class CreateHearts < ActiveRecord::Migration[5.2]
  def change
    create_table :hearts do |t|

      t.timestamps
    end
  end
end

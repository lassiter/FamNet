class CreateFamilyMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :family_members do |t|
      t.references :family, null: false
      t.references :member, null: false
      t.timestamps
    end
  end
end

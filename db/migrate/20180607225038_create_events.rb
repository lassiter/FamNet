class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :title, :null => false
      t.text :description
      t.binary :attachment

      t.datetime :event_start, :null => false
      t.datetime :event_end
      t.boolean :event_allday, default: false

      t.float :location, array: true, precision: 15, scale: 10

      t.boolean :potluck, default: false

      t.boolean :locked, default: false

      t.references :family
      t.references :member
      t.references :event_rsvp, index: true
      t.timestamps
    end
  end
end

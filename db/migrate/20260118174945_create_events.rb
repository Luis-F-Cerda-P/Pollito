class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.text :description
      t.date :start_date
      t.date :end_date

      t.timestamps
    end

    add_index :events, :name, unique: true
  end
end

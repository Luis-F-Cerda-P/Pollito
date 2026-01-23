class CreateStages < ActiveRecord::Migration[8.1]
  def change
    create_table :stages do |t|
      t.string :name
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end

    add_index :stages, [:event_id, :name], unique: true
  end
end

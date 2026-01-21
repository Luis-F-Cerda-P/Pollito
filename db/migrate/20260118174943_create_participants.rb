class CreateParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :participants do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :participants, :name, unique: true
  end
end

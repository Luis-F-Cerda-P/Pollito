class CreateMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :matches do |t|
      t.bigint :event_id, null: false
      t.datetime :match_date, null: true
      t.integer :match_status, null: true
      t.integer :round

      t.timestamps
    end

    add_index :matches, :event_id
    add_index :matches, [ :event_id, :match_date ]

    add_foreign_key :matches, :events
  end
end

class CreateBettingPools < ActiveRecord::Migration[8.0]
  def change
    create_table :betting_pools do |t|
      t.string :name, null: false
      t.boolean :is_public, null: false, default: false
      t.bigint :event_id, null: false
      t.bigint :creator_id, null: false

      t.timestamps
    end

    add_index :betting_pools, :event_id
    add_index :betting_pools, :creator_id
    add_index :betting_pools, [ :event_id, :creator_id ]

    add_foreign_key :betting_pools, :events
    add_foreign_key :betting_pools, :users, column: :creator_id
  end
end

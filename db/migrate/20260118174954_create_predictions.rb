class CreatePredictions < ActiveRecord::Migration[8.0]
  def change
    create_table :predictions do |t|
      t.bigint :betting_pool_id, null: false
      t.bigint :match_id, null: false
      t.bigint :user_id, null: false
      t.integer :predicted_score1, null: false
      t.integer :predicted_score2, null: false

      t.timestamps
    end

    add_index :predictions, :betting_pool_id
    add_index :predictions, :match_id
    add_index :predictions, :user_id
    add_index :predictions, [ :betting_pool_id, :match_id, :user_id ], unique: true

    add_foreign_key :predictions, :betting_pools
    add_foreign_key :predictions, :matches
    add_foreign_key :predictions, :users
  end
end

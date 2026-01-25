class CreatePredictions < ActiveRecord::Migration[8.0]
  def change
    create_table :predictions do |t|
      t.bigint :betting_pool_id, null: false
      t.bigint :match_id, null: false
      t.bigint :user_id, null: false
      t.integer :outcome_points, null: true
      t.integer :total_points, null: true

      t.timestamps
    end

    add_index :predictions, :betting_pool_id
    add_index :predictions, :match_id
    add_index :predictions, :user_id
    add_index :predictions, [ :betting_pool_id, :match_id, :user_id ], unique: true, name: 'index_predictions_on_user_pool_match'

    add_foreign_key :predictions, :betting_pools
    add_foreign_key :predictions, :matches
    add_foreign_key :predictions, :users
  end
end

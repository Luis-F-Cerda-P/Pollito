class CreateBettingPoolMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :betting_pool_memberships do |t|
      t.bigint :betting_pool_id, null: false
      t.bigint :user_id, null: false
      t.string :role, null: false, default: 'member'
      t.integer :score, null: true

      t.timestamps
    end

    add_index :betting_pool_memberships, :betting_pool_id
    add_index :betting_pool_memberships, :user_id
    add_index :betting_pool_memberships, [ :betting_pool_id, :user_id ], unique: true

    add_foreign_key :betting_pool_memberships, :betting_pools
    add_foreign_key :betting_pool_memberships, :users
  end
end

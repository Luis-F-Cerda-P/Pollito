class CreateMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :matches do |t|
      t.bigint :event_id, null: false
      t.bigint :team1_id
      t.bigint :team2_id
      t.integer :score1
      t.integer :score2
      t.datetime :match_date, null: false
      t.integer :round

      t.timestamps
    end

    add_index :matches, :event_id
    add_index :matches, :team1_id
    add_index :matches, :team2_id
    add_index :matches, [ :event_id, :match_date ]

    add_foreign_key :matches, :events
    add_foreign_key :matches, :teams, column: :team1_id
    add_foreign_key :matches, :teams, column: :team2_id
  end
end

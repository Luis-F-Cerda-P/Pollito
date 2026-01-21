class CreateResults < ActiveRecord::Migration[8.1]
  def change
    create_table :results do |t|
      t.references :match_participant, null: false, foreign_key: true, index: { unique: true }
      t.integer :score
      t.boolean :final, null: false, default: false

      t.timestamps
    end
  end
end

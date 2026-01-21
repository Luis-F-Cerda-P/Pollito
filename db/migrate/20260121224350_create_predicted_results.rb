class CreatePredictedResults < ActiveRecord::Migration[8.1]
  def change
    create_table :predicted_results do |t|
      t.references :prediction, null: false, foreign_key: true
      t.references :match_participant, null: false, foreign_key: true
      t.integer :score

      t.timestamps
    end
  end
end

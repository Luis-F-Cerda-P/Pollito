class CreatePredictedResults < ActiveRecord::Migration[8.1]
  def change
    create_table :predicted_results do |t|
      t.references :prediction, null: false, foreign_key: true
      t.references :match_participant, null: false, foreign_key: true
      t.integer :score, null: false

      t.timestamps
    end

    add_index :predicted_results, [ :prediction_id, :match_participant_id ], unique: true, name: 'index_predicted_results_on_prediction_and_participant'
  end
end

class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.string :country_code, null: false

      t.timestamps
    end

    add_index :teams, :name, unique: true
    add_index :teams, :country_code, unique: true
  end
end

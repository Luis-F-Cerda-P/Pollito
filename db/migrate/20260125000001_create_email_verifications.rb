class CreateEmailVerifications < ActiveRecord::Migration[8.1]
  def change
    create_table :email_verifications do |t|
      t.string :email_address, null: false
      t.string :name
      t.string :otp_digest, null: false
      t.integer :purpose, null: false, default: 0
      t.datetime :expires_at, null: false
      t.integer :attempts, null: false, default: 0

      t.timestamps
    end

    add_index :email_verifications, :email_address
    add_index :email_verifications, :expires_at
  end
end

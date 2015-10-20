class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :account_name
      t.string :remote_ip
      t.string :owner_key
      t.string :active_key
      t.string :referer
      t.integer :referer_percent

      t.timestamps null: false
    end

    add_index :accounts, :account_name
    add_index :accounts, :remote_ip
  end
end
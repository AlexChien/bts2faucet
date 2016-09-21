class AddNetworkToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :network, :string, default: 'bts'
  end
end

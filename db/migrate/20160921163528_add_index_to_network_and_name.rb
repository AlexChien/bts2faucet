class AddIndexToNetworkAndName < ActiveRecord::Migration
  def change
    add_index :accounts, [:network, :account_name]
    add_index :referer_stats, [:network, :referer_name]
  end
end
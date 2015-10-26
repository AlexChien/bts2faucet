class AddIndexToRefererOfAccounts < ActiveRecord::Migration
  def change
    add_index :accounts, :referer
  end
end
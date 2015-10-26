class AddIndexToRefererMembershipToAccounts < ActiveRecord::Migration
  def change
    add_index :accounts, [:referer, :membership]
  end
end
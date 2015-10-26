class AddMembershipToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :membership, :string, default: "basic"
  end
end

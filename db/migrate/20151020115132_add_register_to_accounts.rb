class AddRegisterToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :register, :string
  end
end

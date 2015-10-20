class SetDefaultValueToRefererPercentToAccounts < ActiveRecord::Migration
  def change
    change_column_default :accounts, :referer_percent, 0
  end
end
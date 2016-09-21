class AddNetworkToRefererStats < ActiveRecord::Migration
  def change
    add_column :referer_stats, :network, :string, default: 'bts'
  end
end

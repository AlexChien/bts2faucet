class AddStartPercentToRefererStats < ActiveRecord::Migration
  def change
    add_column :referer_stats, :start_percent, :integer, default: 0
  end
end

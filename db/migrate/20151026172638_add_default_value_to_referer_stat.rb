class AddDefaultValueToRefererStat < ActiveRecord::Migration
  def change
    %w(basic annual lifetime).each do |membership|
      change_column_default :referer_stats, membership.to_sym, 0
    end
  end
end
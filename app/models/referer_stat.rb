class RefererStat < ActiveRecord::Base
  has_many :accounts, class_name: "Account", foreign_key: "referer", primary_key: "referer_name"

  # @param refresh_membership: force account to refresh its referee's membership first and then calculate stats
  def update_stat(refresh_membership = false)
    accounts.map(&:update_membership!) if refresh_membership

    accounts.group(:referer, :membership).count(:id).each do |group, count|
      referer, membership = group

      self[membership.to_sym] = count
      save
    end
  end

  def self.update_stats(refresh_membership = false)
    Account.where('membership != "lifetime"').map(&:update_membership!) if refresh_membership

    Account.group(:network, :referer, :membership).count(:id).each do |group, count|
      network, referer, membership = group

      rs = RefererStat.find_or_initialize_by(network: network, referer_name: referer)
      rs[membership.to_sym] = count
      rs.save
    end
  end
end

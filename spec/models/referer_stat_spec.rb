require 'rails_helper'

RSpec.describe RefererStat, type: :model do
  context "association" do
    let!(:account) { create(:account, referer: "refer_site") }
    let!(:referer_stat) { create(:referer_stat, referer_name: "refer_site") }

    it "referer_stat.accounts" do
      expect(referer_stat.accounts.size).to eq 1
      expect(referer_stat.accounts.first).to eq account
    end

    it 'account.stat' do
      expect(account.stat).to eq referer_stat
    end
  end

  context "#self.update_stats and #update_stat" do
    let!(:account0) { build(:account, referer: "a", membership: "basic").save(validate: false) }
    let!(:account1) { build(:account, referer: "a", membership: "lifetime").save(validate: false) }
    let!(:account2) { build(:account, referer: "a", membership: "lifetime").save(validate: false) }
    let!(:account3) { build(:account, referer: "a", membership: "annual").save(validate: false) }
    let!(:account4) { build(:account, referer: "b", membership: "annual").save(validate: false) }

    before(:each) do
      RefererStat.update_stats
    end

    it "should have 2 stats" do
      expect(RefererStat.count).to eq 2
    end

    it '1 a.basic' do
      a = RefererStat.where(referer_name: 'a').first
      expect(a.basic).to eq 1
    end

    it '2 a.lifetime' do
      a = RefererStat.where(referer_name: 'a').first
      expect(a.lifetime).to eq 2
    end

    it '1 a.annual' do
      a = RefererStat.where(referer_name: 'a').first
      expect(a.annual).to eq 1
    end

    it '1 b.annual' do
      b = RefererStat.where(referer_name: 'b').first
      expect(b.basic).to eq 0
      expect(b.annual).to eq 1
      expect(b.lifetime).to eq 0
    end

    it 'a.lifetime update' do
      rs = RefererStat.where(referer_name: 'a').first
      rs.update_attribute(:lifetime, 0)
      rs.reload

      rs.update_stat
      expect(rs.lifetime).to eq 2
    end
  end
end

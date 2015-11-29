require 'rails_helper'

RSpec.describe Account, type: :model do
  context "account_name" do
    let(:account) { build(:account) }

    it "premium name should be invalid" do
      account.account_name = "abcde"

      expect(account.valid?).to be false
      expect(account.errors.full_messages).to include(I18n.t("active_record.errors.messages.premium_name_not_support"))
    end

    it 'abc.com suffix should be invalid' do
      account.account_name = "abc-d.com"

      expect(account.valid?).to be false
      expect(account.errors.full_messages).to include(I18n.t("active_record.errors.messages.dot_com_name_not_support"))

      # while this is ok
      account.account_name = "a.comb"
      expect(account.valid?).to be true
    end

    it 'name contains dot or dash is valid' do
      %w(abc-de abc.de ab-c.de).each do |name|
        account.account_name = name
        expect(account.valid?).to be true
      end
    end

    it "name contain no vowls is valid" do
      account.account_name = "bcd"

      expect(account.valid?).to be true
    end
  end

  context "frequency" do
    it 'it should fail too soon' do
      last_reg = create(:account)
      account = build(:account, account_name: "a-b#{rand(100000)}")

      expect(account.valid?).to be false
    end

    it 'it should success if 10 minutes passed' do
      last_reg = create(:account)
      # time flies
      last_reg.update_column(:created_at, Time.now - Rails.application.secrets[:frequency_limit] - 1)

      account = build(:account, account_name: "a-b#{rand(100000)}")

      expect(account.valid?).to be true
    end
  end

  context "referer_percentage", :focus do
    let!(:baozou0) { create(:referer_stat, referer_name: "baozou0", start_percent: 30)}
    let!(:baozou60) { create(:referer_stat, referer_name: "baozou60", lifetime: 60, start_percent: 30)}
    let!(:user) { create(:referer_stat, referer_name: "user", lifetime: 0)}

    it "new referer should get basic percent" do
      expect(Account.calculate_referer_percent('newuser')).to eq Rails.application.secrets[:bts]["referer_percent"]
    end

    it "progress plan 0-5" do
      user.lifetime = 3; user.save

      expect(Account.calculate_referer_percent('user')).to eq 20
    end

    it "progress plan 6-20" do
      user.lifetime = 20; user.save

      expect(Account.calculate_referer_percent('user')).to eq 40
    end

    it "progress plan 21-50" do
      user.lifetime = 21; user.save

      expect(Account.calculate_referer_percent('user')).to eq 60
    end

    it "progress plan >50" do
      user.lifetime = 70; user.save

      expect(Account.calculate_referer_percent('user')).to eq 80
    end


    it "with start_percent set lm 0" do
      expect(Account.calculate_referer_percent(baozou0.referer_name)).to eq 30
    end

    it "with start_percent set lm 60" do
      expect(Account.calculate_referer_percent(baozou60.referer_name)).to eq 80
    end
  end
end

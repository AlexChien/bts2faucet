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
end

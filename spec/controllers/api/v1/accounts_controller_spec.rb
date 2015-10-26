require 'rails_helper'

RSpec.describe Api::V1::AccountsController, type: :controller do

  let!(:premium_name) { "abcd#{rand(10000)}"}
  let!(:account_name) { "abcd-rspec-#{Time.now.to_i}" }
  let!(:owner_key) { "BTS8k7WQULvghUPYS1BVo3G96koQxLFh1Z4wpnuX85uJTFX5trVMT" }
  let!(:active_key) { "BTS8k7WQULvghUPYS1BVo3G96koQxLFh1Z4wpnuX85uJTFX5trVMT" }

  let!(:register) { "boombastic" }
  let!(:referer) { "mr.agsexplorer" }
  let!(:referer_percent) { 30 }


  describe "post #create" do

    before(:each) do
      @body = {
        account: {
          name: account_name,
          owner_key: owner_key,
          active_key: active_key
        }
      }
    end

    it "premium name will fail" do
      @body[:account][:name] = premium_name

      post :create, @body

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include(I18n.t('active_record.errors.messages.premium_name_not_support'))
    end

    it "returns http success" do
      post :create, @body
      expect(response).to have_http_status(:created)

      expect( Account.exists?(account_name: account_name) ).to be true

    end

    it "frequency limit" do
      create(:account, remote_ip: "0.0.0.0")

      @body[:account][:name] += "2"
      post :create, @body

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include(I18n.t('active_record.errors.messages.too_frequent'))
    end
  end

end

FactoryGirl.define do
  factory :account do
    account_name {"my-string#{rand(100000)}"}
    remote_ip "192.168.1.1"
    owner_key "BTS8k7WQULvghUPYS1BVo3G96koQxLFh1Z4wpnuX85uJTFX5trVMT"
    active_key "BTS8k7WQULvghUPYS1BVo3G96koQxLFh1Z4wpnuX85uJTFX5trVMT"
    referer "mr.agsexplorer"
    referer_percent 30
  end

end

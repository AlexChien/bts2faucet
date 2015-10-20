class Account < ActiveRecord::Base
  validates_presence_of :account_name, :remote_ip, :owner_key, :active_key, :referer

  validate :reject_premium_account_name
  validates :account_name, presence: true, uniqueness: true, format: /\A[a-z][a-z0-9\-\.]*[a-z0-9]\Z/
  validate :frequency_check

  class Error < RuntimeError; end

  def self.register(name, okey, akey, ip, register = nil, referer = nil)
    default_register = Rails.application.secrets[:bts]["register"]
    referer_percent  = Rails.application.secrets[:bts]["referer_percent"]

    account = Account.new(
      account_name: name.downcase,
      owner_key: okey,
      active_key: akey,
      remote_ip: ip,
      register: default_register,
      referer: referer || default_register,
      referer_percent: referer_percent
    )

    # check model validity
    raise Error, account.errors.full_messages unless account.valid?

    # check if it's registered already
    raise Error, I18n.t('active_record.errors.messages.account_name_taken') unless account_available_on_chain?(account.account_name)

    begin
      registered_account = register_on_chain(account)
      account.save! if registered_account

      registered_account
    rescue Exception => e
      raise Error, I18n.t('active_record.errors.messages.unable_register_onchain')
    end

  end

  def self.register_on_chain(account)
    Graphene::API.rpc.request('register_account',
      [account.account_name, account.owner_key, account.active_key, account.register, account.referer, account.referer_percent, true])
  end

  def self.account_available_on_chain?(account_name)
    Graphene::API.rpc.request('get_account', [account_name]).present?
  rescue Exception => e
    false
  end

  private

  # account name should contain dash or dot
  # or contains no vowles
  def reject_premium_account_name
    valid = false

    if account_name =~ /[-.]/ || !/[aeiou]/.match(account_name)
      return true
    end

    errors[:base] << I18n.t('active_record.errors.messages.premium_name_not_support') unless valid
  end

  # same remote_ip must not register again within 10 minutes
  def frequency_check
    return true unless Account.exists?(remote_ip: remote_ip)

    last_reg = Account.where(remote_ip: remote_ip).order("created_at desc").first

    if (Time.now - last_reg.created_at) < Rails.application.secrets[:frequency_limit]
      errors[:base] << I18n.t('active_record.errors.messages.too_frequent')
    end
  end
end

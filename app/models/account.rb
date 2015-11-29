class Account < ActiveRecord::Base
  validates_presence_of :account_name, :remote_ip, :owner_key, :active_key, :referer

  validate :reject_premium_account_name
  validate :reject_dot_com_name
  validates :account_name, presence: true, uniqueness: true, format: /\A[a-z][a-z0-9\-\.]*[a-z0-9]\Z/
  validate :frequency_check

  belongs_to :stat, :class_name => "RefererStat", :foreign_key => "referer", :primary_key => "referer_name"

  MEMBERSHIPS = %w(basic annual lifetime)

  class Error < RuntimeError; end

  def self.register(name, okey, akey, ip, referer = nil, register = nil)
    default_register = Rails.application.secrets[:bts]["register"]

    # if no referer set or referer does not exist on chain
    if referer.blank? || account_available_on_chain?(referer) || !is_premium_account?(referer)
      referer = default_register
    end

    # check referer percentage
    referer_percent = calculate_referer_percent(referer)

    account = Account.new(
      account_name: name.downcase,
      owner_key: okey,
      active_key: akey,
      remote_ip: ip,
      register: default_register,
      referer: referer,
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

  rescue Errno::ECONNREFUSED => e
    raise Error, I18n.t('active_record.errors.messages.network_down')
  end

  # check if account is annual subscriber or lifetime account
  def self.is_premium_account?(account_name)
    membership = member_status(account_name)

    membership == 'lifetime' || membership == 'annual'
  end

  # register account on chain
  def self.register_on_chain(account)
    Graphene::API.rpc.request('register_account',
      [account.account_name, account.owner_key, account.active_key, account.register, account.referer, account.referer_percent, true])
  end

  # get account's membership status
  # @return lifetime, annual, basic or nil for un-existed account
  def self.member_status(account_name)
    acct = get_account_onchain(account_name)
    return nil if acct.nil?

    return 'lifetime' if acct["lifetime_referrer"] == acct["id"]

    expiration_date = acct["membership_expiration_date"]
    exp_time = begin
      Time.parse expiration_date
    rescue
      Time.parse "1970-01-01T00:00:00"
    end
    now = Time.now

    exp_time < now ? "basic" : "annual"
  end

  def self.account_available_on_chain?(account_name)
    !Graphene::API.rpc.request('get_account', [account_name])

  rescue Errno::ECONNREFUSED => e
    raise Errno::ECONNREFUSED
  rescue Exception => e
    true
  end

  def self.get_account_onchain(account_name)
    Graphene::API.rpc.request('get_account', [account_name])
  rescue Exception => e
    nil
  end

  def update_membership!
    membership = Account.member_status(account_name)
    self.update_attribute(:membership, membership) if !membership.nil? && self.membership != membership
  end

  # update account's current membership status
  def self.update_membership!(account = nil)
    accounts = account.nil? ? self.all : [account]
    accounts.each do |account|
      account.update_membership!
    end
  end


  private

  # progress plan
  #
  # 升级数量  推荐人配比  注册人配比  网络收取配比
  # 0-5      40%        40%        20%
  # 6-20    50%        30%        20%
  # 21-50    60%        20%        20%
  # >51     70%        10%        20%
  #
  # referer can have a manually set start_percent value
  # some opinion leader wants to have higher refer percentage to start
  # it's suppported by setting a start_percent
  # real percetage will be max(start_percent, LM_based_calculated_percent)
  def self.calculate_referer_percent(referer_name)
    stat = RefererStat.find_by_referer_name(referer_name)
    start_percent = stat.try(:start_percent).to_i

    lm_count = stat.try(:lifetime).to_i
    calculated_percent = if lm_count <= 5
      20
    elsif lm_count <= 20
      40
    elsif lm_count <= 50
      60
    else
      80
    end

    return [start_percent, calculated_percent, Rails.application.secrets[:bts]["referer_percent"]].max
  end

  # account name should contain dash or dot
  # or contains no vowles
  def reject_premium_account_name
    valid = false

    if account_name =~ /[-.]/ || !/[aeiou]/.match(account_name)
      return true
    end

    errors[:base] << I18n.t('active_record.errors.messages.premium_name_not_support') unless valid
  end

  def reject_dot_com_name
    if account_name =~ /\.com\Z/
      errors[:base] << I18n.t('active_record.errors.messages.dot_com_name_not_support')
    end
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

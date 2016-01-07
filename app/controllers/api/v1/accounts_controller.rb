class Api::V1::AccountsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  respond_to :json

  # register user account using faucet account
  def create
    render status: :bad_request and return unless account_params

    account = Account.register(
      account_params[:name],
      account_params[:owner_key],
      account_params[:active_key],
      request.remote_ip,
      account_params[:referer]
    )

    render status: :created, json: {account: account_params.merge({accountid:nil}) }

  rescue Exception => e
    render status: :unprocessable_entity, json: { error: { base: [e.message] }}
  end

  # return account's referral stats
  def referral_stats
    account_name = stats_params[:id]
    stat = RefererStat.where(referer_name: account_name).select(:basic, :annual, :lifetime).first
    if stat
      render status: :ok, json: {account: account_name, stats: stat}
    else
      render status: :not_found, json: { error: { base: ["not_found"] }}
    end
  end

  private
  def account_params
    params[:account].permit(:id, :name, :owner_key, :active_key, :referer, :refcode, :memo_key)
  end

  def stats_params
    params.permit(:id)
  end
end

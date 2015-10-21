class Api::V1::AccountsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  respond_to :json

  def create
    render status: :bad_request and return unless account_param

    account = Account.register(
      account_param[:name],
      account_param[:owner_key],
      account_param[:active_key],
      request.remote_ip,
      account_param[:referer]
    )

    render status: :created, json: {account: account_param.merge({accountid:nil}) }

  rescue Exception => e
    render status: :unprocessable_entity, json: { error: { base: [e.message] }}
  end

  def options
    head :ok
  end

  def account_param
    params[:account].permit(:name, :owner_key, :active_key, :referer)
  end
end

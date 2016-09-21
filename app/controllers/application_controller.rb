class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :network

  def network
    @network ||= if !!(request.host =~ /pls2faucet/)
      # "pls2"
      "bts"
    else
      "bts"
    end
  end
end

require 'Graphene/graphene_api.rb'

gconf = Rails.application.secrets[:bts]
Graphene::Wrapper.bts = Graphene::API.init(
  gconf["host"],
  gconf["port"],
  gconf["user"],
  gconf["password"],
  logger: Rails.logger,
  instance_name: 'btsrpc'
)

gconf = Rails.application.secrets[:pls2]
Graphene::Wrapper.pls2 = Graphene::API.init(
  gconf["host"],
  gconf["port"],
  gconf["user"],
  gconf["password"],
  logger: Rails.logger,
  instance_name: 'pls2rpc'
)
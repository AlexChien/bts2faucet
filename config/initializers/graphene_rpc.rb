require 'Graphene/graphene_api.rb'

gconf = Rails.application.secrets[:bts]
Graphene::API.init(
  gconf["host"],
  gconf["port"],
  gconf["user"],
  gconf["password"],
  logger: Rails.logger,
  instance_name: 'bts2rpc'
)


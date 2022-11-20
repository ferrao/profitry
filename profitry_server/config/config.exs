import Config

config :profitry_server,
  clock: Profitry.Application.Clock

import_config "#{config_env()}.exs"

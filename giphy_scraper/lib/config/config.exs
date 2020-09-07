# This file is responsible for configuring the application
import Config

config :giphy_scraper,
    api_key: ""

import_config "#{config_env()}.exs"
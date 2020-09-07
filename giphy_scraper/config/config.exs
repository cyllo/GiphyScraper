# This file is responsible for configuring the application
import Config

config :giphy_scraper,
    api_key: ""

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
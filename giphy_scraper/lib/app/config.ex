defmodule GiphyScraper.Config do
    @app :giphy_scraper
    def api_key() do Application.get_env(@app, :api_key) end
end
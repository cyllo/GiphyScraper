defmodule GiphyScraper.Type.SearchResult do
    alias GiphyScraper.Type.GiphyImage
    @type giphy_search_result :: list(GiphyImage.giphy_image)
end
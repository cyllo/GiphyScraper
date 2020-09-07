defmodule GiphyScraper.Type.GiphyImage do
    @type giphy_image :: %{
        id: String.t,
        url: String.t,
        author: String.t,
        title: String.t,
        type: String.t
    }
    @enforce_keys [:id, :url, :author, :title, :type]
    defstruct [:id, :url, :author, :title, :type]
end
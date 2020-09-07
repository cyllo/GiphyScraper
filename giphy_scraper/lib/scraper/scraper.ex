defmodule GiphyScraper.Scraper do

    @moduledoc """
    Documentation for `GiphyScraper.Scraper`.
    This module is used to handle search requests
    """

    alias HTTPoison.Error
    alias HTTPoison.Response
    alias GiphyScraper.Helper
    alias GiphyScraper.Type.GiphyImage
    alias GiphyScraper.Type.SearchResult 
    
    @keyword [search_gif_endpoint: "api.giphy.com/v1/gifs/search"]

    @doc """
    Sends search query request to giphy and returns result

    ## Examples

        iex> GiphyScraper.Scraper.search("konosuba")

    """
    @spec search(String.t) :: SearchResult.giphy_search_result
    def search(query) when is_binary(query) and not (query === "") do
        case Application.ensure_all_started(:giphy_scraper) do
            {:ok, _started} -> 
                #Start HTTPoison and its dependencies.
                HTTPoison.start()
                case GiphyScraper.Config.api_key() do
                    {:ok, api_key} -> p_search_giphy_for_gif(query, api_key)
                    _error -> {:error, "Failed to get API key"}
                end
            {:error, reason} -> {:error, reason}
        end
    end

    @doc """
    Returns an error for bad search argument
    """
    @spec search(any()) :: tuple()
    def search(_) do
        {:error, "Bad argument"}
    end

    @doc """
    Handles API call to Giphy GIF search endpoint
    """
    @spec p_search_giphy_for_gif(String.t, String.t, non_neg_integer()) :: SearchResult.giphy_search_result
    def p_search_giphy_for_gif(query, giphy_api_key, limit \\ 3) when is_binary(query) and not (query === "") do
        #Get the giphy search api endpoint
        giphy_search_endpoint = @keyword[:search_gif_endpoint]
        #Create a request object for the query
        request = %HTTPoison.Request{
            method: :get,
            url: giphy_search_endpoint,
            body: "",
            headers: [{"Accept", "application/json"}],
            options: [
                params: %{ 
                    api_key: giphy_api_key,
                    q: query,
                    lang: "en",
                    limit: limit
                }
            ]
            
        }
        #Handle the result
        case HTTPoison.request(request) do
            {:ok, %Response{status_code: 200, body: body}} -> p_get_list_of_giphy_images_from_body(body)
            {:ok, %Response{status_code: 404}} -> {:error, "Not found."}
            {:error, %Error{reason: reason}} -> {:error, reason}
        end
    end

    @spec p_get_list_of_giphy_images_from_body(iodata()) :: list(%GiphyImage{})
    defp p_get_list_of_giphy_images_from_body(body) do
        %{"data" => data} = Helper.decode_json(body)
        result = Enum.map(data, fn gif_object ->
            %{
                "id" => id,
                "url" => url,
                "username" => username,
                "title" => title,
                "type" => type
            } = gif_object
            %GiphyImage{id: id, url: url, author: username, title: title, type: type}
        end)
        {:ok, result}
    end
    
end
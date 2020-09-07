defmodule GiphyScraper.Scraper.Scraper do
    @moduledoc """
    Documentation for `GiphyScraper.Scraper`.
    This module is used to handle search requests
    """

    alias GiphyScraper.Type.GiphyImage
    
    @app :giphy_scraper
    @keyword [search_gif_endpoint: "api.giphy.com/v1/gifs/search"]

    @doc """
    Sends search query request to giphy and returns result

    ## Examples

        iex> GiphyScraper.Scraper.Scraper.search("konosuba")
        {:ok,
        [
        %GiphyScraper.Type.GiphyImage{
            author: "",
            id: "mwErnt1MeDBcs",
            title: "avatar cabbage GIF",
            type: "gif",
            url: "https://giphy.com/gifs/reaction-avatar-cabbage-mwErnt1MeDBcs"
        },
        %GiphyScraper.Type.GiphyImage{
            author: "",
            id: "gV0lvve9qDk9W",
            title: "rick springfield GIF",
            type: "gif",
            url: "https://giphy.com/gifs/rick-springfield-gV0lvve9qDk9W"
        },
        %GiphyScraper.Type.GiphyImage{
            author: "",
            id: "jleNxE9BsJVO8",
            title: "Animated GIF",
            type: "gif",
            url: "https://giphy.com/gifs/jleNxE9BsJVO8"
        }
        ]}

    """
    @spec search(String.t) :: list(%GiphyImage{})
    def search(query) when is_binary(query) and not (query === "") do
        case Application.ensure_all_started(:giphy_scraper) do
            {:ok, _started} -> 
                #Start HTTPoison and its dependencies.
                HTTPoison.start()
                search_for_gif(query)
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

    #Handles the api call
    @spec search_for_gif(String.t, non_neg_integer()) :: tuple()
    defp search_for_gif(query, limit \\ 3)  when is_binary(query) and not (query === "") do
        api_key = api_key_from_env()
        case api_key do
            {:ok, api_key} -> 
                giphy_search_endpoint = @keyword[:search_gif_endpoint]
                headers = [{"Accept", "application/json"}]
                options = [
                    params: %{ 
                        api_key: api_key,
                        q: query,
                        lang: "en",
                        limit: limit
                    }
                ]
                response = HTTPoison.get(giphy_search_endpoint, headers, options)
                case response do
                    {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> parse_giphy_images_from_body(body)
                    {:ok, %HTTPoison.Response{status_code: 404}} -> {:error, "Not found."}
                    {:ok, _unknown} -> {:error, "Unknown response."}
                    {:error, %HTTPoison.Error{reason: reason}} -> {:error, reason}
                    _error -> {:error, "Unknown error."}
                end
            {:error, error} -> {:error, error}
        end
    end

    # Gets the api key from env var
    @spec api_key_from_env :: tuple()
    defp api_key_from_env do
        api_key = Application.get_env(@app, :api_key, nil)
        if not (api_key === nil) do
            {:ok, api_key}
        else
            {:error, "Failed to get API key."}
        end
    end

    # Parses the json body and returns list of %GiphyImage{}
    @spec parse_giphy_images_from_body(String.t) :: list(%GiphyImage{})
    defp parse_giphy_images_from_body(body) do
        %{"data" => data} = decode_json(body)
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

    # Decodes the json data
    @spec decode_json(String.t) :: tuple()
    defp decode_json(body) do
        case Jason.decode(body) do
            {:ok, data} -> data
            {:error, error} -> error
        end
    end
    
end
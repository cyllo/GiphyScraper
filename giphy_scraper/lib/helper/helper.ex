defmodule GiphyScraper.Helper do
    @spec decode_json(iodata()) :: tuple()
    def decode_json(body) do
        case Jason.decode(body) do
            {:ok, data} -> data
            {:error, error} -> error
        end
    end
end
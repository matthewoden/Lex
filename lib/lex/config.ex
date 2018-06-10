defmodule Lex.Config do
    @moduledoc false
    use Agent

    @doc false
    def start_link(config) do
      region = Map.get(config, :region, "us-east-1")

      config = %{
        session_timeout: Map.get(config, :session_timeout, 60 * 1000 * 5),
        json_parser: Map.get(config, :json_parser, Lex.Json.Jason),
        http_adapter: get_or_raise(config, :http_adapter),
        region: region,
        model_url: "https://models.lex.#{region}.amazonaws.com",
        runtime_url: "https://runtime.lex.#{region}.amazonaws.com",
        access_key_id: get_or_raise(config, :aws_access_key_id),
        secret_access_key: get_or_raise(config, :aws_secret_access_key),
      }

      Agent.start_link(fn -> config end, name: __MODULE__)
    end

    defp get_or_raise(config, key) do
      case Map.get(config, key) do
        nil -> raise "Config key #{key} is required."
        otherwise -> otherwise
      end
    end

    @doc false
    def get(key) do
      Agent.get(__MODULE__, &Map.get(&1, key))
    end
 

end
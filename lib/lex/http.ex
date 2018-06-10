defmodule Lex.Http do
  import HttpBuilder
  alias Lex.{Config, Json}

  @moduledoc """
  Http Client for Lex. Transforms Lex Requests to `HttpBuilder` requests.
  """

  @doc """
  Posts text to the configured AWS runtime endpoint.
  """
  @spec post_text(Lex.Runtime.Request.t) :: Lex.Runtime.Response.t
  def post_text(%Lex.Runtime.Request{} = request) do
    post_text_with_retry(request, 0)
  end

  defp client() do
    HttpBuilder.new()
    |> with_adapter(Config.get(:http_adapter).adapter())
    |> with_host(Config.get(:runtime_url))
    |> with_json_parser(Json)
  end

  defp post_text_with_retry(%Lex.Runtime.Request{} = request, 3) do
    Lex.Runtime.Response.Error.cast(request.user_id, {:error, :too_many_retries })
  end

  defp post_text_with_retry(%Lex.Runtime.Request{} = request, retries) do
    body = %{ "inputText" => request.input }
    body = if request.session_attributes, do: Map.put(body, "sessionAttributes", request.session_attributes), else: body
    body = if request.request_attributes, do: Map.put(body, "requestAttributes", request.request_attributes), else: body

    user_id = "#{request.bot_alias}_#{request.user_id}_#{request.context}"
    url = "/bot/#{request.bot_name}/alias/#{request.bot_alias}/user/#{user_id}/text"

    aws_response =
      client()
      |> post(url)
      |> with_json_body(body)
      |> sign_request()
      |> send()
      |> Config.get(:http_adapter).format_response()

    case parse_response(aws_response) do
      {:ok, body } ->
        Lex.Runtime.Response.cast(request.user_id, request.context, body)

      {:error, { :internal_server_error, _body } } ->
        post_text_with_retry(request, retries + 1)

      {:error, result } ->
        Lex.Runtime.Response.Error.cast(request.user_id, result)
    end
  end

  defp sign_request(request) do
    body = elem(request.body, 1) |>  Json.encode!()
    url = "#{request.host}#{request.path}"
    headers = Map.new(request.headers)
    method = cast_method(request.method)

    headers = AWSAuth.sign_authorization_header(
      Config.get(:access_key_id),
      Config.get(:secret_access_key), 
      method, 
      url, 
      Config.get(:region), 
      "lex", 
      headers,
      body
    )

    HttpBuilder.with_headers(request, headers)
  end

  defp cast_method(:get), do: "GET"
  defp cast_method(:post), do: "POST"
  defp cast_method(:put), do: "PUT"
  defp cast_method(:patch), do: "PATCH"

  defp parse_response({ status, body } = request) do
    # documented responses from AWS
    case status do
      200 -> {:ok, Json.decode!(body) }
      400 -> {:error, {:bad_request, request} }
      404 -> {:error, {:not_found, request} }
      409 -> {:error, {:conflict, request} }
      429 -> {:error, {:too_many_requests, request} }
      500 -> {:error, {:internal_server_error, request } }
      502 -> {:error, {:bad_gateway, request } }
      _  ->  {:error, {:unknown, request } }
    end
  end
  
end
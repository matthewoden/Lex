defmodule Lex.Http.Adapter do

  @type request :: Lex.Runtime.Request.t
  @type response :: { integer, String.t }

  @type json :: map() | list()
  @type error :: :bad_gateway | :bad_request | :conflict | 
    :internal_server_error | :too_many_requests | :not_found | :unknown

  @callback format_response(response) :: { :ok, json } | {:error, { error, term } }

end

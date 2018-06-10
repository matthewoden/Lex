# Lex

`Lex` attempts to create a broker between your chat application, and Amazon's Lex Chatbot API.

  Currently, Lex only supports the Runtime API. There are two main modules around
  runtime requests and responses.
  
  * `Lex.Runtime.Request` - a set of methods used for building Lex Requests.

  * `Lex.Runtime.Response` - a set of structs based on the AWS reply. 
  You can be as specific or general as you want, based on the type of reply

  In the background is a conversation store, which tracks user conversations 
  across various contexts. This can be handy for things like slack, where a 
  user may interact with a bot in multiple channels, in multiple threads, or 
  in private messages.

  ## Example usage
  ``` elixir
  defmodule SlackProxy do

    alias Lex.Runtime.{Request, Response}

    def converse(user, context, message) do
      lex_reply = 
        Request.new()
        |> Request.set_bot_name("Slackbot")
        |> Request.set_bot_alias("dev")
        |> Request.set_context(context)
        |> Request.set_user_id(user)
        |> Request.set_text_input(message)
        |> Request.send()

      case lex_reply do
        %Response.ReadyForFulfillment{ user_id: user, intent_name: intent, slots: slots } ->
          case intent do
            "DadJokes" ->
              message = DadJokeApi.fetch()
              SomeChatLibrary.reply(user, message)

            "Documentation Search" ->
              message = Documentation.fetch()
              SomeChatLibrary.reply(user, message)
          end

        %Response.Error{ } ->
          SomeChatLibrary.reply(user, "Something went wrong, try again later.")

        # catchall for any other response - just send whatever Lex replies.
        %{ message: message } ->
          SomeChatLibrary.reply(user, message)
      end
    end
  end
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `lex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:lex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/lex](https://hexdocs.pm/lex).


defmodule Lex do

  @moduledoc """
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
  """
  use Supervisor

  @doc """
  Starts the supervisor for Lex's conversation and configuration stores.

  ## Supervisor Configuration
  The supervisor takes an object for configuration.

  ### Required Keys
  The supervisor will fail to start if these are not provided.

  * `:aws_access_key_id` - Your AWS access key id.
  * `:aws_secret_access_key` - Your AWS secret key.
  * `:http_adapter` - Your `Lex.Http` adapter, which extends `HttpBuilder`
  * `:json_parser` - Your `Lex.Json` parser. (`Jason` and `Poison` should work without any special adapters.)

  ### Optional Keys
  These options have reasonable defaults.

  * `:session_timeout` - How long Lex should track conversations. Defaults to 5 minutes.
  * `:region` - Your AWS region, needed for signing and determining Lex Urls. Defaults to "us-east-1"
  """
  def start_link(config \\ %{}) do
    # List all child processes to be supervised
    children = [
      { Lex.Config, config },
      { Lex.Runtime.Conversations, [] },
    ]

    opts = [
      strategy: :one_for_one, 
      name: Lex.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end

end

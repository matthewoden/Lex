defmodule Lex.Runtime.Conversations do
  alias Lex.Config
  use GenServer

  @moduledoc """
  A store of currently active conversations. Conversations are stored
  until timeout. To configure this value, set `:session_timeout` in the 
  initial config to an integer representing the number of seconds 
  to wait before cleanup.
  """

  @type user :: String.t
  @type context :: String.t
  @type conversations :: %{ optional({ user, context }) => NaiveDateTime.t }

  @doc false
  def start_link(_) do
     GenServer.start_link(__MODULE__,  %{ conversations: %{} }, [name: __MODULE__])
  end

  def init(state) do
    schedule_cleanup()
    {:ok, state }
  end

  @doc """
  Checks if there is a conversation occuring in the current context (thread, 
  private message, channel, etc)
  """
  @spec in_conversation?(user, context) :: boolean
  def in_conversation?(user, context \\ "default") do
    GenServer.call(__MODULE__, {:is_conversing, {user, context}})
  end


  @doc """
  Returns a map of current conversations, keyed by user id and context, with a
  NaiveDateTime representing the expiration as the value
  """
  @spec conversations() :: conversations
  def conversations() do
    GenServer.call(__MODULE__, :conversations)
  end

  @doc false
  @spec converse(user, context) :: :ok
  def converse(user, context \\ "default", timeout) do
    GenServer.cast(__MODULE__, {:converse, user, context})
  end

  @doc false
  @spec complete(user, context) :: :ok
  def complete(user, context \\ "default") do
    GenServer.cast(__MODULE__, {:complete, user, context})
  end

  # Cleanup

  defp schedule_cleanup() do
    Process.send_after(self(), :cleanup, 60 * 1000)
  end

  defp valid_connversations(state) do
    conversations =
      state.conversations
      |> Enum.filter(fn {_, expires} -> 
          now = NaiveDateTime.utc_now()
          expires < now
        end)
      |> Map.new()
  
    Map.put(state, :conversations, conversations)
  end

  # Genserver 
  ################

  @doc false
  def handle_info(:cleanup, state) do
    {:noreply, valid_connversations(state)}
  end

  @doc false
  def handle_info(_, state), do: {:noreply, state}

  @doc false
  def handle_call({:is_conversing, key}, _from, state) do
    response = 
      case Map.get(state.conversations, key) do
        nil ->
          false

        expires ->
          case NaiveDateTime.compare(expires, NaiveDateTime.utc_now()) do
            :gt -> 
              true
            _ ->
              false
          end
      end

    {:reply, response, state}
  end

  @doc false
  def handle_call(:conversations, _from, state) do
    state = valid_connversations(state)
    {:reply, state.conversations, state}
  end

  @doc false
  def handle_cast({:converse, user, context}, state) do
    expires_at = 
      NaiveDateTime.utc_now() 
      |> NaiveDateTime.add(Config.get(:session_timeout), :seconds)

    conversations = Map.put(state.conversations, {user, context}, expires_at)
    state = Map.put(state, :conversations, conversations)

    {:noreply, state}
  end
  
  @doc false
  def handle_cast({:complete, user, context}, state) do
    conversations = Map.delete(state.conversations, {user, context})
    {:noreply, Map.put(state, :conversations, conversations)}
  end

end
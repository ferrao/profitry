defmodule Profitry.Exchanges.Subscribers.DummySubscriber do
  @moduledoc """

  Dummy Subscriber, usefull for logging or inspecting exchange data

  """
  use Task

  require Logger

  alias Profitry.Exchanges

  @doc """

  Starts the dummy subscriber process

  """
  @spec start_link(keyword()) :: {:ok, pid()}
  def start_link(_opts) do
    Task.start_link(__MODULE__, :run, [])
  end

  @doc """

  Subscribes to exchange quotes and prints debug messages when they arrive

  """
  @spec run() :: nil
  def run() do
    Exchanges.subscribe_quotes()
    listen()
  end

  @spec listen() :: nil
  defp listen do
    receive do
      {:new_quote, quote} ->
        Logger.debug("#{quote}")

        listen()
    end
  end
end

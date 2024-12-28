defmodule Profitry.Exchanges.PollBehaviour do
  @moduledoc """
  Behaviour for exchanges that can be polled for quotes
  """

  alias Profitry.Exchanges.Schema.Quote

  @doc """

  Initializes the Exchange Client

  """
  @callback init() :: keyword()

  @doc """

  Gets the interval to poll the Exchange

  """
  @callback interval() :: integer()

  @doc """

  Gets a quote from the Exchange

  """
  @callback quote(String.t(), keyword()) :: {:ok, Quote.t()} | {:error, any()}
end

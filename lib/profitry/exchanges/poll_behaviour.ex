defmodule Profitry.Exchanges.PollBehaviour do
  @moduledoc """
  Behaviour for exchanges that can be polled for quotes
  """

  alias Profitry.Exchanges.Schema.Quote

  @callback init() :: keyword()
  @callback interval() :: integer()
  @callback quote(String.t(), keyword()) :: {:ok, Quote.t()} | {:error, any()}
end

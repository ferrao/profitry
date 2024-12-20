defmodule Profitry.Exchanges.PollBehaviour do
  @moduledoc """
  Behaviour for exchanges that can be polled for quotes
  """

  alias Profitry.Exchanges.Schema.Quote

  @callback interval() :: integer()
  @callback quote(String.t()) :: {:ok, Quote.t()} | {:error, any()}
end

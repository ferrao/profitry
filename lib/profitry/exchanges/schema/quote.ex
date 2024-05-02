defmodule Profitry.Exchanges.Schema.Quote do
  @moduledoc """

  Schema representing a stock or option quote 

  """

  @type t :: %__MODULE__{
          ticker: String.t() | nil,
          price: Decimal.t() | nil,
          timestamp: DateTime.t() | nil
        }

  defstruct [:ticker, :price, :timestamp]
end

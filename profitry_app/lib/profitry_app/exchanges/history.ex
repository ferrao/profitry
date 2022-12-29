defmodule ProfitryApp.Exchanges.History do
  use GenServer

  alias ProfitryApp.Exchanges
  alias Profitry.Exchanges.Quote

  @type t() :: %__MODULE__{
          quotes: %{String.t() => Quote.t()}
        }
  defstruct [:quotes]

  def get_quote(pid, ticker) do
    GenServer.call(pid, {:get_quote, ticker})
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(_init_args) do
    {:ok, %__MODULE__{quotes: %{}}, {:continue, :subscribe}}
  end

  def handle_continue(:subscribe, history) do
    Exchanges.subscribe()
    {:noreply, history}
  end

  def handle_info(quote, history) do
    new_history = Map.put(history, quote.ticker, quote)
    {:noreply, new_history}
  end

  def handle_call({:get_quote, ticker}, _from, history) do
    {:reply, Map.get(history, ticker), history}
  end
end

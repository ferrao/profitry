defmodule ProfitryApp.Exchanges.History do
  use GenServer

  require Logger

  alias ProfitryApp.Exchanges
  alias ProfitryApp.Exchanges.Quote

  @type t() :: %__MODULE__{
          quotes: %{String.t() => Quote.t()}
        }
  defstruct [:quotes]

  def get_quote(pid \\ __MODULE__, ticker) do
    GenServer.call(pid, {:get_quote, ticker})
  end

  def start_link(opts \\ []) when is_list(opts) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def init(_init_args) do
    {:ok, %__MODULE__{quotes: %{}}, {:continue, :subscribe}}
  end

  def handle_continue(:subscribe, history) do
    Exchanges.subscribe_quotes()
    {:noreply, history}
  end

  def handle_info(quote, history) do
    Logger.debug(quote)

    new_history = Map.put(history, quote.ticker, quote)
    {:noreply, new_history}
  end

  def handle_call({:get_quote, ticker}, _from, history) do
    {:reply, Map.get(history, ticker), history}
  end
end

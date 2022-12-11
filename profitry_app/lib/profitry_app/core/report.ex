defmodule ProfitryApp.Core.Report do
  use Ecto.Schema

  alias ProfitryApp.Core.Position

  schema "reports" do
    field :ticker, :string
    field :investment, :decimal
    field :shares, :decimal
    field :cost_basis, :decimal
  end

  def make_report(%Position{} = position) do
    %__MODULE__{
      id: position.id,
      ticker: position.ticker,
      investment: 0,
      shares: 0,
      cost_basis: 0
    }
  end
end

defmodule ProfitryApp.Exchanges.Finnhub.FinnhubQuote do
  use Ecto.Schema

  import Ecto.Changeset

  alias ProfitryApp.Exchanges.Quote
  alias ProfitryApp.Utils.{UnixTime, Errors}

  @primary_key false
  embedded_schema do
    field :c, :decimal
    field :d, :decimal
    field :dp, :decimal
    field :h, :decimal
    field :l, :decimal
    field :o, :decimal
    field :pc, :decimal
    field :t, UnixTime
  end

  def new(ticker, data) do
    quote_from_data(ticker, changeset(data))
  end

  def changeset(data \\ %{}) do
    %__MODULE__{}
    |> cast(data, [:c, :d, :dp, :h, :l, :o, :pc, :t])
    |> validate_required([:c, :t])
  end

  defp quote_from_data(ticker, %Ecto.Changeset{valid?: true} = changeset) do
    data = Ecto.Changeset.apply_changes(changeset)

    %Quote{
      ticker: ticker,
      price: data.c,
      timestamp: data.t
    }
  end

  defp quote_from_data(_ticker, changeset), do: {:error, Enum.at(Errors.get_errors(changeset), 0)}
end

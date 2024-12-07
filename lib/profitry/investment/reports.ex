defmodule Profitry.Investment.Reports do
  @moduledoc """

    Generate a report on a portfolio position

  """

  alias Profitry.Investment.Schema.Split
  alias Profitry.Exchanges.Schema.Quote
  alias Profitry.Investment.Schema.OptionsReport
  alias Profitry.Investment.Schema.{Position, PositionReport, Order, Option}

  import Profitry.Investment.Schema.Option, only: [option_value: 1]

  @doc """

  Creates a report on a portfolio position, adjusting for stock splits

  ## Examples

      iex> make_report(position, quote, splits)
      %PositionReport{}

  """
  @spec make_report(Position.t(), Quote.t(), list(Split.t())) :: PositionReport.t()
  def make_report(
        %Position{id: id, ticker: ticker, orders: orders},
        quote \\ %Quote{},
        splits \\ []
      ) do
    report = %PositionReport{id: id, ticker: ticker}

    {_last_order, report} =
      Enum.reduce(orders, {nil, report}, fn order, {last_order, report} ->
        split = find_relevant_split(splits, last_order, order)
        report = apply_split(report, split)

        {order, calculate_order(report, order)}
      end)

    has_shares = Decimal.gt?(report.shares, 0)

    report
    |> PositionReport.calculate_cost_basis(has_shares)
    |> PositionReport.calculate_profit(quote.price)
    |> PositionReport.calculate_value(quote.price)
    |> Map.put(:price, quote.price || Decimal.new(0))
    |> Map.put(:ticker, ticker)
  end

  # buy stock
  @doc false
  @spec calculate_order(PositionReport.t(), Order.t()) :: PositionReport.t()
  def calculate_order(report, %Order{
        type: :buy,
        instrument: :stock,
        quantity: quantity,
        price: price
      }) do
    %PositionReport{
      report
      | investment: Decimal.add(report.investment, stock_investment(quantity, price)),
        shares: Decimal.add(report.shares, quantity)
    }
  end

  # sell stock
  @doc false
  @spec calculate_order(PositionReport.t(), Order.t()) :: PositionReport.t()
  def calculate_order(report, %Order{
        type: :sell,
        instrument: :stock,
        quantity: quantity,
        price: price
      }) do
    %PositionReport{
      report
      | investment: Decimal.sub(report.investment, stock_investment(quantity, price)),
        shares: Decimal.sub(report.shares, quantity)
    }
  end

  # buy premium
  @doc false
  @spec calculate_order(PositionReport.t(), Order.t()) :: PositionReport.t()
  def calculate_order(report, %Order{
        type: :buy,
        instrument: :option,
        quantity: quantity,
        price: price,
        option: %Option{
          strike: strike,
          expiration: expiration
        }
      }) do
    %PositionReport{
      report
      | investment: Decimal.add(report.investment, option_investment(quantity, price)),
        long_options:
          OptionsReport.update_reports(report.long_options, %OptionsReport{
            strike: strike,
            expiration: expiration,
            contracts: quantity,
            investment: option_investment(quantity, price)
          })
    }
  end

  # sell premium
  @doc false
  @spec calculate_order(PositionReport.t(), Order.t()) :: PositionReport.t()
  def calculate_order(report, %Order{
        type: :sell,
        instrument: :option,
        quantity: quantity,
        price: price,
        option: %Option{
          strike: strike,
          expiration: expiration
        }
      }) do
    %PositionReport{
      report
      | investment: Decimal.sub(report.investment, option_investment(quantity, price)),
        short_options:
          OptionsReport.update_reports(report.short_options, %OptionsReport{
            strike: strike,
            expiration: expiration,
            contracts: quantity,
            investment: Decimal.mult(option_investment(quantity, price), -1)
          })
    }
  end

  @doc false
  @spec apply_split(PositionReport.t(), Split.t()) :: PositionReport.t()

  def apply_split(report, nil), do: report

  def apply_split(report, _split) do
    # TODO: Apply the split to the report stock and options positions
    report
  end

  @doc false
  @spec find_relevant_split(list(Split.t()), Order.t(), Order.t()) :: Split.t() | nil
  def find_relevant_split(splits, last_order, order) do
    Enum.filter(splits, fn split ->
      {:ok, split_ts} = NaiveDateTime.new(split.date, ~T[00:00:00])

      NaiveDateTime.after?(split_ts, last_order.inserted_at) &&
        NaiveDateTime.before?(split_ts, order.inserted_at)
    end)
    |> List.first()
  end

  @spec stock_investment(Decimal.t(), Decimal.t()) :: Decimal.t()
  defp stock_investment(quantity, price), do: Decimal.mult(quantity, price)

  @spec stock_investment(Decimal.t(), Decimal.t()) :: Decimal.t()
  defp option_investment(quantity, price), do: Decimal.mult(quantity, option_value(price))
end

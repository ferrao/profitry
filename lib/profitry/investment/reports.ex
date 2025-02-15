defmodule Profitry.Investment.Reports do
  @moduledoc """

    Generate a report on a portfolio position

  """

  alias Profitry.Utils.Date, as: DateUtils
  alias Profitry.Investment.Schema.Split
  alias Profitry.Exchanges.Schema.Quote
  alias Profitry.Investment.Schema.OptionsReport
  alias Profitry.Investment.Schema.{Position, PositionReport, Order, Option}

  import Profitry.Investment.Schema.Option, only: [option_value: 1]

  @doc """

  Creates a report on a portfolio position, adjusting for stock splits
  NOTE: Requires orders to be properly sorted by date or report will be incorrect

  ## Examples

      iex> make_report(position, quote, splits)
      %PositionReport{}

  """
  @spec make_report(Position.t(), Quote.t() | nil, list(Split.t())) :: PositionReport.t()

  def make_report(
        %Position{id: id, ticker: ticker, orders: orders},
        quote \\ nil,
        splits \\ []
      ) do
    %PositionReport{id: id, ticker: ticker}
    |> consolidate_orders(orders, splits)
    |> calculate_report(quote)
  end

  @doc false
  @spec consolidate_orders(PositionReport.t(), list(Order.t()), list(Split.t())) ::
          PositionReport.t()
  def consolidate_orders(report, [], _splits), do: report

  def consolidate_orders(report, orders, splits) do
    {first_orders, rest_orders} = Enum.split(orders, 1)

    order = first_orders |> List.first()
    rest_orders = Enum.concat(rest_orders, [nil])

    # Iterate through orders, acc contains a tupple with the order to consolidate
    # and a consolidated report of previous processed orders {order, report}
    #
    # On each iteration, we need the next order to check if a stock split is applicable
    {nil, report} =
      Enum.reduce(rest_orders, {order, report}, fn next_order, {order, report} ->
        report = calculate_order(report, order)

        report =
          find_relevant_split(splits, order, next_order)
          |> apply_split(report)

        {next_order, report}
      end)

    report
  end

  @doc """

  Checks if position is closed

  """
  @spec position_closed?(PositionReport.t()) :: boolean()
  def position_closed?(position_report) do
    options_expired?(position_report.long_options) &&
      options_expired?(position_report.short_options) &&
      Decimal.eq?(position_report.shares, 0)
  end

  @spec options_expired?(list(OptionsReport.t())) :: boolean()
  defp options_expired?(option_reports) do
    Enum.all?(option_reports, fn option_report ->
      !DateUtils.after_today?(option_report.expiration)
    end)
  end

  @doc false
  @spec calculate_report(PositionReport.t(), Quote.t() | nil) :: PositionReport.t()
  def calculate_report(report, quote) do
    has_shares = Decimal.gt?(report.shares, 0)
    quote_price = if quote, do: quote.price, else: nil

    report
    |> PositionReport.calculate_cost_basis(has_shares)
    |> PositionReport.calculate_profit(quote_price)
    |> PositionReport.calculate_value(quote_price)
    |> Map.put(:price, quote_price || Decimal.new(0))
    |> Map.put(:ticker, report.ticker)
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
          type: type,
          strike: strike,
          expiration: expiration
        }
      }) do
    %PositionReport{
      report
      | investment: Decimal.add(report.investment, option_investment(quantity, price)),
        long_options:
          OptionsReport.update_reports(report.long_options, %OptionsReport{
            type: type,
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
  def calculate_order(
        report,
        %Order{
          type: :sell,
          instrument: :option,
          quantity: quantity,
          price: price,
          option: %Option{
            type: type,
            strike: strike,
            expiration: expiration
          }
        }
      ) do
    %PositionReport{
      report
      | investment: Decimal.sub(report.investment, option_investment(quantity, price)),
        short_options:
          OptionsReport.update_reports(report.short_options, %OptionsReport{
            type: type,
            strike: strike,
            expiration: expiration,
            contracts: quantity,
            investment: Decimal.mult(option_investment(quantity, price), -1)
          })
    }
  end

  @doc false
  @spec apply_split(Split.t(), PositionReport.t()) :: PositionReport.t()

  def apply_split(nil, report), do: report

  @doc false
  def apply_split(split, report) when split.reverse === false do
    %PositionReport{
      report
      | shares: Decimal.mult(report.shares, split.multiple),
        long_options: apply_split_options(split, report.long_options),
        short_options: apply_split_options(split, report.short_options)
    }
  end

  @doc false
  def apply_split(split, report) when split.reverse === true do
    %PositionReport{
      report
      | shares: Decimal.div(report.shares, split.multiple),
        long_options: apply_split_options(split, report.long_options),
        short_options: apply_split_options(split, report.short_options)
    }
  end

  @doc false
  @spec apply_split_options(Split.t(), list(OptionsReport.t())) :: list(OptionsReport.t())
  def apply_split_options(split, option_reports) when split.reverse === false do
    Enum.map(option_reports, fn option_report ->
      if Date.before?(Date.add(split.date, -1), option_report.expiration),
        do: %OptionsReport{
          option_report
          | contracts: Decimal.mult(option_report.contracts, split.multiple),
            strike: Decimal.div(option_report.strike, split.multiple)
        },
        else: option_report
    end)
  end

  @doc false
  @spec apply_split_options(Split.t(), list(OptionsReport.t())) :: list(OptionsReport.t())
  def apply_split_options(split, option_reports) when split.reverse === true do
    Enum.map(option_reports, fn option_report ->
      if Date.before?(Date.add(split.date, -1), option_report.expiration),
        do: %OptionsReport{
          option_report
          | contracts: Decimal.div(option_report.contracts, split.multiple),
            strike: Decimal.mult(option_report.strike, split.multiple)
        },
        else: option_report
    end)
  end

  @doc false
  @spec find_relevant_split(list(Split.t()), Order.t(), Order.t()) :: Split.t() | nil
  def find_relevant_split(splits, order, next_order) do
    Enum.filter(splits, fn split ->
      {:ok, split_ts} = NaiveDateTime.new(split.date, ~T[00:00:00])
      ts_after_order?(split_ts, order) && ts_before_order?(split_ts, next_order)
    end)
    |> List.first()
  end

  @spec ts_after_order?(NaiveDateTime.t(), Order.t() | nil) :: boolean()
  defp ts_after_order?(ts, order) do
    NaiveDateTime.after?(ts, order.inserted_at)
  end

  @spec ts_before_order?(NaiveDateTime.t(), Order.t() | nil) :: boolean()
  defp ts_before_order?(_ts, nil), do: true

  defp ts_before_order?(ts, order) do
    NaiveDateTime.before?(ts, order.inserted_at)
  end

  @spec stock_investment(Decimal.t(), Decimal.t()) :: Decimal.t()
  defp stock_investment(quantity, price), do: Decimal.mult(quantity, price)

  @spec stock_investment(Decimal.t(), Decimal.t()) :: Decimal.t()
  defp option_investment(quantity, price), do: Decimal.mult(quantity, option_value(price))
end

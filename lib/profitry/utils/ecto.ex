defmodule Profitry.Utils.Ecto do
  @moduledoc """

    Ecto related utilities

  """

  @doc """

  Capitalize changes on a Changeset

  """
  @spec capitalize(Ecto.Changeset.t(), list(atom())) :: Ecto.Changeset.t()
  def capitalize(changeset, fields) when is_list(fields) do
    Enum.reduce(fields, changeset, fn field, changeset -> capitalize(changeset, field) end)
  end

  @spec capitalize(Ecto.Changeset.t(), atom()) :: Ecto.Changeset.t()
  def capitalize(changeset, field) do
    case Ecto.Changeset.get_change(changeset, field) do
      nil -> changeset
      value -> Ecto.Changeset.put_change(changeset, field, String.upcase(value))
    end
  end

  @doc """

  Validates if two fields are not equal

  """
  @spec validate_not_equal(Ecto.Changeset.t(), atom(), atom()) :: Ecto.Changeset.t()
  def validate_not_equal(changeset, field1, field2) do
    value1 = Ecto.Changeset.get_field(changeset, field1)
    value2 = Ecto.Changeset.get_field(changeset, field2)

    if value1 == value2 do
      Ecto.Changeset.add_error(changeset, field2, "#{field2} cannot be the same as #{field1}")
    else
      changeset
    end
  end
end

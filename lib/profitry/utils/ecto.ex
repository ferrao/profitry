defmodule Profitry.Utils.Ecto do
  @moduledoc """

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
end

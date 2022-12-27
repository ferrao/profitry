defmodule ProfitryApp.Utils.Errors do
  def get_message(%Ecto.Changeset{} = changeset, field) do
    case Map.fetch(get_errors(changeset), field) do
      {:ok, msg} ->
        msg

      :error ->
        nil
    end
  end

  def get_errors(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {constraint, _opts} ->
      constraint
    end)
  end
end

defmodule ProfitryApp.Utils.Errors do
  def get_message(%Ecto.Changeset{} = changeset, field) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {constraint, _opts} ->
        constraint
      end)

    case Map.fetch(errors, field) do
      {:ok, msg} ->
        msg

      :error ->
        nil
    end
  end
end

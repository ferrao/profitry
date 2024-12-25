defmodule Profitry.Utils.Errors do
  @doc """

  Gets the error message for a field of an Ecto Changeset error map

  """
  @spec get_message(Ecto.Changeset.t(), atom(), String.t() | nil) :: [String.t() | nil]
  @spec get_message(Ecto.Changeset.t(), atom()) :: [String.t() | nil]
  def get_message(%Ecto.Changeset{} = changeset, field, default_msg \\ nil) do
    case Map.fetch(get_errors(changeset), field) do
      {:ok, msg} ->
        msg

      :error ->
        default_msg
    end
  end

  @doc """

  Traverses the list of errors in the changeset and
  returns a map of errors for each association

  """
  @spec get_errors(Ecto.Changeset.t()) :: Ecto.Changeset.traverse_result()
  def get_errors(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end

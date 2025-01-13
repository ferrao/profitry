defmodule Profitry.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Profitry.Repo

  alias Profitry.Accounts.{User, UserToken, UserNotifier}

  ## Database getters
  @spec get_user_by_email_token(binary(), String.t()) :: User.t() | nil
  def get_user_by_email_token(token, context) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, context),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  @spec get_user_by_email(String.t()) :: User.t() | nil
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(number()) :: User.t()
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec register_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_user_email(User.t(), map()) :: Ecto.Changeset.t()
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  @spec apply_user_email(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def apply_user_email(user, attrs) do
    user
    |> User.email_changeset(attrs)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  @spec update_user_email(User.t(), binary()) :: :ok | :error
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  @spec user_email_multi(User.t(), String.t(), String.t()) :: Ecto.Multi.t()
  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """
  @spec deliver_user_update_email_instructions(User.t(), String.t(), fun()) ::
          {:ok, Swoosh.Email.t()}
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  ## Session

  @doc """
  Generates a session token.
  """
  @spec generate_user_session_token(User.t()) :: binary()
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  @spec get_user_by_session_token(binary()) :: User.t() | nil
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  @spec delete_user_session_token(binary()) :: :ok
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc """
  Confirms a user. Does nothing if they're already confirmed.
  """
  # NOTE: You could add a last_seen_at timestamp update here.
  @spec confirm_user(User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def confirm_user(%User{confirmed_at: confirmed_at} = user) when is_nil(confirmed_at) do
    user
    |> User.confirm_changeset()
    |> Repo.update()
  end

  @spec confirm_user(User.t()) :: {:ok, User.t()}
  def confirm_user(%User{confirmed_at: confirmed_at} = user) when not is_nil(confirmed_at) do
    {:ok, user}
  end

  ## Authentication

  @spec login_or_register_user(String.t()) :: {:ok, Swoosh.Email.t()} | :error
  def login_or_register_user(email) do
    case get_user_by_email(email) do
      # Found existing user.
      %User{} = user -> login(user)
      # New user, create a new account.
      _ -> register(email, Application.fetch_env!(:profitry, __MODULE__)[:register])
    end
  end

  @spec login(User.t()) :: {:ok, Swoosh.Email.t()}
  def login(user) do
    {email_token, token} = UserToken.build_email_token(user, "magic_link")
    Repo.insert!(token)

    UserNotifier.deliver_login_link(
      user,
      "#{ProfitryWeb.Endpoint.url()}/login/email/token/#{email_token}"
    )
  end

  @spec register(String.t(), boolean()) :: {:ok, Swoosh.Email.t()} | :error

  def register(_email, false) do
    :error
  end

  def register(email, _can_register) do
    {:ok, user} = register_user(%{email: email})

    {email_token, token} = UserToken.build_email_token(user, "magic_link")
    Repo.insert!(token)

    UserNotifier.deliver_register_link(
      user,
      "#{ProfitryWeb.Endpoint.url()}/login/email/token/#{email_token}"
    )
  end
end

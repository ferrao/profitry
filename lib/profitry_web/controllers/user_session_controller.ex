defmodule ProfitryWeb.UserSessionController do
  use ProfitryWeb, :controller

  alias Profitry.Accounts
  alias Profitry.Accounts.User
  alias ProfitryWeb.UserAuth

  def send_magic_link(conn, params) do
    %{"user" => %{"email" => email}} = params

    Accounts.login_or_register_user(email)

    conn
    |> put_flash(:info, "We've sent an email to #{email} with a one-time sign-in link.")
    |> redirect(to: ~p"/login")
  end

  def login_with_token(conn, %{"token" => token} = _params) do
    case Accounts.get_user_by_email_token(token, "magic_link") do
      %User{} = user ->
        {:ok, user} = Accounts.confirm_user(user)

        conn
        |> put_flash(:info, "Logged in successfully.")
        |> UserAuth.login_user(user)

      _ ->
        conn
        |> put_flash(:error, "That link didn't seem to work. Please try again.")
        |> redirect(to: ~p"/login")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.logout_user()
  end
end

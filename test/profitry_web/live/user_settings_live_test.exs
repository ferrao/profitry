defmodule ProfitryWeb.UserSettingsLiveTest do
  use ProfitryWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Profitry.AccountsFixtures

  describe "Log in page" do
    test "renders log in page", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/login")

      assert html =~ "Sign In"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> login_user(user_fixture())
        |> live(~p"/login")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end
  end

  describe "user login" do
    test "creates a user if one does not exist with that email, and send the link", %{conn: conn} do
      email = "email@doesnotexist.com"

      assert is_nil(Profitry.Repo.get_by(Profitry.Accounts.User, email: email))
      assert is_nil(find_token_for_email(email))

      {:ok, view, _html} = live(conn, ~p"/login")

      form = form(view, "#magic_link_form", user: %{email: email})

      _conn = submit_form(form, conn)

      refute is_nil(Profitry.Repo.get_by(Profitry.Accounts.User, email: email))
      refute is_nil(find_token_for_email(email))
    end

    test "if user already exists, send the link but don't create a new one", %{conn: conn} do
      email = "email@doesnotexist.com"

      assert is_nil(Profitry.Repo.get_by(Profitry.Accounts.User, email: email))
      assert is_nil(find_token_for_email(email))

      {:ok, view, _html} = live(conn, ~p"/login")

      form = form(view, "#magic_link_form", user: %{email: email})

      _conn = submit_form(form, conn)

      refute is_nil(Profitry.Repo.get_by(Profitry.Accounts.User, email: email))
      refute is_nil(find_token_for_email(email))
    end
  end

  def find_token_for_email(email) do
    import Ecto.Query

    Profitry.Accounts.UserToken
    |> join(:inner, [ut], u in assoc(ut, :user))
    |> where([ut, u], u.email == ^email)
    |> Profitry.Repo.one()
  end
end

defmodule ProfitryWeb.UserLoginLive do
  use ProfitryWeb, :live_view

  alias Profitry.Accounts

  @impl true
  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    socket =
      socket
      |> assign(form: form)
      |> assign(:status, :not_sent)

    {:ok, socket, temporary_assigns: [form: form]}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div :if={@status == :not_sent} class="mx-auto max-w-md">
      <.header class="text-center">
        Sign In to Your Account
        <:subtitle>No password needed: we'll send you an email!</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="magic_link_form"
        action={~p"/login"}
        phx-update="ignore"
        phx-submit="send-magic-link"
        class="my-0 py-0"
      >
        <.input field={@form[:email]} type="email" label="Email" required />
        <:actions>
          <.button
            class="w-full flex place-content-center place-items-center gap-2"
            phx-disable-with="Sending email..."
          >
            Send me a link <.icon name="hero-envelope" />
          </.button>
        </:actions>
      </.simple_form>
    </div>

    <div :if={@status == :sent} class="mx-auto">
      <.header class="text-center">
        Check your email!
        <:subtitle>
          We sent you a link to sign in.
        </:subtitle>
      </.header>
    </div>
    """
  end

  @impl true
  def handle_event("send-magic-link", params, socket) do
    %{"user" => %{"email" => email}} = params

    case Accounts.login_or_register_user(email) do
      {:ok, _} ->
        socket =
          socket
          |> put_flash(:info, "We've sent an email to #{email}, with a one-time sign-in link.")
          |> assign(:status, :sent)

        {:noreply, socket}

      :error ->
        {:noreply, socket |> put_flash(:error, "Unable to register new user")}
    end
  end
end

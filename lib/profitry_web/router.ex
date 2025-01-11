defmodule ProfitryWeb.Router do
  use ProfitryWeb, :router

  import ProfitryWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ProfitryWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ProfitryWeb do
    pipe_through :browser
    get "/", PageController, :home
  end

  scope "/", ProfitryWeb do
    pipe_through([:browser, :require_authenticated_user])

    live "/portfolios", PortfolioLive.Index, :list
    live "/portfolios/new", PortfolioLive.Index, :new
    live "/portfolios/:id/edit", PortfolioLive.Index, :edit

    live "/splits", SplitLive.Index, :list
    live "/splits/new", SplitLive.Index, :new
    live "/splits/:id/edit", SplitLive.Index, :edit

    live "/portfolios/:id", PositionLive.Index, :list
    live("/portfolios/:id/positions/new", PositionLive.Index, :new)
    live("/portfolios/:id/positions/:ticker/edit", PositionLive.Index, :edit)

    live("/portfolios/:portfolio_id/positions/:ticker/orders", OrderLive.Index, :list)
    live("/portfolios/:portfolio_id/positions/:ticker/orders/new", OrderLive.Index, :new)
    live("/portfolios/:portfolio_id/positions/:ticker/orders/:id/edit", OrderLive.Index, :edit)
  end

  # Other scopes may use custom stacks.
  # scope "/api", ProfitryWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:profitry, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ProfitryWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", ProfitryWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ProfitryWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/login", UserLoginLive, :new
    end

    post "/login", UserSessionController, :send_magic_link
    get "/login/email/token/:token", UserSessionController, :login_with_token
  end

  scope "/", ProfitryWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ProfitryWeb.UserAuth, :ensure_authenticated}] do
      live "/settings", UserSettingsLive, :edit
      live "/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", ProfitryWeb do
    pipe_through [:browser]

    delete "/logout", UserSessionController, :delete
  end
end

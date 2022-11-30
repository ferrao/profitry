defmodule ProfitryAppWeb.Router do
  use ProfitryAppWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {ProfitryAppWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ProfitryAppWeb do
    pipe_through(:browser)

    get("/", PageController, :home)

    live("/portfolios", PortfolioLive.Index, :index)
    live("/portfolios/new", PortfolioLive.Index, :new)
    live("/portfolios/:id/edit", PortfolioLive.Index, :edit)

    live("/portfolios/:id", PortfolioLive.Show, :show)
    live("/portfolios/:id/show/edit", PortfolioLive.Show, :edit)
  end

  # Other scopes may use custom stacks.
  # scope "/api", ProfitryAppWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:profitry_app, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: ProfitryAppWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end

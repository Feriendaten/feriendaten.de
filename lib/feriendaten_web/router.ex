defmodule FeriendatenWeb.Router do
  use FeriendatenWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {FeriendatenWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug FeriendatenWeb.Plugs.SetDates
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FeriendatenWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", FeriendatenWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:feriendaten, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FeriendatenWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end

    scope "/admin", FeriendatenWeb.Admin, as: :admin do
      pipe_through :browser

      resources "/levels", LevelController
      resources "/locations", LocationController
      resources "/addresses", AddressController
    end
  end

  # Enable admin routes in test
  if Mix.env() == :test do
    scope "/admin", FeriendatenWeb.Admin, as: :admin do
      pipe_through :browser

      resources "/levels", LevelController
      resources "/locations", LocationController
      resources "/addresses", AddressController
    end
  end
end

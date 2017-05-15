defmodule PipeDream.Web.Router do
  use PipeDream.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PipeDream.Web do
    pipe_through :browser # Use the default browser stack

    get "/", ElmController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", PipeDream.Web do
  #   pipe_through :api
  # end
end

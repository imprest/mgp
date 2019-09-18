defmodule MgpWeb.Router do
  use MgpWeb, :router

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

  scope "/", MgpWeb do
    pipe_through :browser

    get "/", PageConroller, :index
    get "/*path", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", MgpWeb do
  #   pipe_through :api
  # end
end

defmodule MgpWeb.Router do
  use MgpWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug(:assign_current_user)
    plug(:ensure_authenticated)
  end

  # Authenticated api
  scope "/api", MgpWeb do
    pipe_through([:api, :api_auth])
    # get("/file/:id", FileController, only: [:show]
    resources("/session", SessionController, only: [:delete], singleton: true)
  end

  scope "/api", MgpWeb do
    pipe_through :api

    get "/raw", PageController, :raw
    resources("/session", SessionController, only: [:create], singleton: true)
  end

  scope "/", MgpWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/*path", PageController, :index
  end

  # Plug function
  defp assign_current_user(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Mgp.Accounts.get_user(user_id)
    assign(conn, :current_user, user)
  end

  defp ensure_authenticated(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must login first!!")
      |> redirect(to: MgpWeb.Router.Helpers.session_path(conn, :index))
      |> halt()
    end
  end
end

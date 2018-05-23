defmodule MgpWeb.SessionController do
  use MgpWeb, :controller

  alias Mgp.Accounts
  alias Mgp.Accounts.User

  plug(:scrub_params, "user" when action in [:create])

  action_fallback(MgpWeb.FallbackController)

  def index(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "login.html", changeset: changeset)
  end

  def create(conn, %{"user" => %{"username" => username, "password" => password}}) do
    case Accounts.authenticate_user(username, password) do
      {:ok, user} ->
        conn
        |> assign(:current_user, user)
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> redirect(to: MgpWeb.Router.Helpers.page_path(conn, :index))

      {:error, reason} ->
        conn
        |> put_flash(:info, reason)
        |> render("login.html", changeset: User.changeset(%User{}))
    end
  end

  def delete(conn, _params) do
    changeset = User.changeset(%User{})

    conn
    |> configure_session(drop: true)
    |> render("login.html", changeset: changeset)
  end
end

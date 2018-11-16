defmodule MgpWeb.SessionController do
  use MgpWeb, :controller

  alias Mgp.Accounts

  plug(:scrub_params, "user" when action in [:create])

  action_fallback MgpWeb.FallbackController

  # TODO: on create session return Phoenix.Token to client
  def create(conn, %{"user" => %{"username" => username, "password" => password}}) do
    case Accounts.authenticate_user(username, password) do
      {:ok, user} ->
        conn
        |> assign(:current_user, user)
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> json(%{token: "asdfasdfasdf"})

      {:error, reason} ->
        json(conn, %{error: reason})
    end
  end

  # TODO: on delete; invalidate Phoenix.Token
  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> json(%{ok: "logged out"})
  end
end

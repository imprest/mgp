defmodule MgpWeb.UserView do
  use MgpWeb, :view
  alias MgpWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      username: user.username,
      password: user.password,
      is_active: user.is_active,
      is_admin: user.is_admin,
      role: user.role
    }
  end
end
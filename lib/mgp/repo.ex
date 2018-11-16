defmodule Mgp.Repo do
  use Ecto.Repo,
    otp_app: :mgp,
    adapter: Ecto.Adapters.Postgres
end

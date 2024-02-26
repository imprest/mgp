defmodule Mgp.Repo do
  use Ecto.Repo,
    otp_app: :mgp,
    timeout: :infinity,
    adapter: Ecto.Adapters.Postgres
end

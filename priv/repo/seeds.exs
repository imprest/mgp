# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Mgp.Repo.insert!(%Mgp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Mgp.Accounts.create_user(%{username: "hvaria", password: "admin", is_admin: true, role: "manager"})

# Mgp.Repo.insert!(%TaxRate{id: "NTX", description: "NO TAX", rate: Decimal.new(0)});
# Mgp.Repo.insert!(%TaxRate{id: "VEX", description: "VAT EXEMPTED", rate: Decimal.new(0)});
# Mgp.Repo.insert!(%TaxRate{id: "V15", description: "15% VAT", rate: Decimal.new("15.00")});
# Mgp.Repo.insert!(%TaxRate{id: "V17", description: "17.5% VAT", rate: Decimal.new("17.50")});

# Repo.insert_all(TaxRate,
#   [
#     %{id: "NTX", description: "DONT KNOW", rate: Decimal.new(0), inserted_at: Ecto.DateTime.cast!("2017-07-31T12:00:00"), updated_at: Ecto.DateTime.utc},
#     %{id: "NEW", description: "DONT KNOW", rate: Decimal.new(0), inserted_at: Ecto.DateTime.cast!("2017-07-31T12:00:00"), updated_at: Ecto.DateTime.utc},
#     %{id: "NEW", description: "DONT KNOW", rate: Decimal.new(0), inserted_at: Ecto.DateTime.cast!("2017-07-31T12:00:00"), updated_at: Ecto.DateTime.utc},
#     %{id: "NEW", description: "DONT KNOW", rate: Decimal.new(0), inserted_at: Ecto.DateTime.cast!("2017-07-31T12:00:00"), updated_at: Ecto.DateTime.utc},
#   ]
# );

# q = Product |> where(id: "IMP BIOFIL 10ML") |> update(set: [description: "test"])
# Repo.update_all(q, [])

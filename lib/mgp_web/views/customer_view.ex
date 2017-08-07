defmodule MgpWeb.CustomerView do
  use MgpWeb, :view
  alias MgpWeb.CustomerView

  def render("index.json", %{customers: customers}) do
    %{data: render_many(customers, CustomerView, "customer.json")}
  end

  def render("show.json", %{customer: customer}) do
    %{data: render_one(customer, CustomerView, "customer.json")}
  end

  def render("customer.json", %{customer: customer}) do
    %{id: customer.id,
      region: customer.region,
      description: customer.description,
      attn: customer.attn,
      add1: customer.add1,
      add2: customer.add2,
      add3: customer.add3,
      phone: customer.phone,
      is_gov: customer.is_gov,
      resp: customer.resp,
      email: customer.email,
      lmu: customer.lmu,
      lmd: customer.lmd,
      lmt: customer.lmt}
  end
end

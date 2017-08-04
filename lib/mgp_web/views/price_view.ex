defmodule MgpWeb.PriceView do
  use MgpWeb, :view
  alias MgpWeb.PriceView

  def render("index.json", %{prices: prices}) do
    %{data: render_many(prices, PriceView, "price.json")}
  end

  def render("show.json", %{price: price}) do
    %{data: render_one(price, PriceView, "price.json")}
  end

  def render("price.json", %{price: price}) do
    %{id: price.id,
      date: price.date,
      cash: price.cash,
      credit: price.credit,
      trek: price.trek,
      lmu: price.lmu,
      lmd: price.lmd,
      lmt: price.lmt}
  end
end

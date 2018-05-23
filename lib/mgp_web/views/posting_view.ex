defmodule MgpWeb.PostingView do
  use MgpWeb, :view
  alias MgpWeb.PostingView

  def render("index.json", %{postings: postings}) do
    %{data: render_many(postings, PostingView, "posting.json")}
  end

  def render("show.json", %{posting: posting}) do
    %{data: render_one(posting, PostingView, "posting.json")}
  end

  def render("posting.json", %{posting: [id, date, description, amount, balance]}) do
    %{
      id: id,
      date: to_date(date),
      description: description,
      amount: amount,
      balance: balance
    }
  end

  def render("posting.json", %{posting: posting}) do
    %{
      id: posting.id,
      date: posting.date,
      description: posting.description,
      amount: posting.amount,
      lmu: posting.lmu,
      lmd: posting.lmd,
      lmt: posting.lmt
    }
  end

  defp to_date({y, m, d}) do
    {:ok, date} = Date.new(y, m, d)
    date
  end
end

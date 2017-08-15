defmodule MgpWeb.PostingView do
  use MgpWeb, :view
  alias MgpWeb.PostingView

  def render("index.json", %{postings: postings}) do
    %{data: render_many(postings, PostingView, "posting.json")}
  end

  def render("show.json", %{posting: posting}) do
    %{data: render_one(posting, PostingView, "posting.json")}
  end

  def render("posting.json", %{posting: posting}) do
    %{id: posting.id,
      date: posting.date,
      description: posting.description,
      amount: posting.amount,
      lmu: posting.lmu,
      lmd: posting.lmd,
      lmt: posting.lmt}
  end
end

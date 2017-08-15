defmodule MgpWeb.PostingController do
  use MgpWeb, :controller

  alias Mgp.Accounts
  alias Mgp.Accounts.Posting

  action_fallback MgpWeb.FallbackController

  def index(conn, _params) do
    postings = Accounts.list_postings()
    render(conn, "index.json", postings: postings)
  end

  def create(conn, %{"posting" => posting_params}) do
    with {:ok, %Posting{} = posting} <- Accounts.create_posting(posting_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", posting_path(conn, :show, posting))
      |> render("show.json", posting: posting)
    end
  end

  def show(conn, %{"id" => id}) do
    posting = Accounts.get_posting!(id)
    render(conn, "show.json", posting: posting)
  end

  def update(conn, %{"id" => id, "posting" => posting_params}) do
    posting = Accounts.get_posting!(id)

    with {:ok, %Posting{} = posting} <- Accounts.update_posting(posting, posting_params) do
      render(conn, "show.json", posting: posting)
    end
  end

  def delete(conn, %{"id" => id}) do
    posting = Accounts.get_posting!(id)
    with {:ok, %Posting{}} <- Accounts.delete_posting(posting) do
      send_resp(conn, :no_content, "")
    end
  end
end

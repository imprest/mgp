defmodule MgpWeb.PostingControllerTest do
  use MgpWeb.ConnCase

  alias Mgp.Accounts
  alias Mgp.Accounts.Posting

  @create_attrs %{amount: "some amount", date: ~D[2010-04-17], description: "some description", lmd: ~D[2010-04-17], lmt: ~T[14:00:00.000000], lmu: "some lmu"}
  @update_attrs %{amount: "some updated amount", date: ~D[2011-05-18], description: "some updated description", lmd: ~D[2011-05-18], lmt: ~T[15:01:01.000000], lmu: "some updated lmu"}
  @invalid_attrs %{amount: nil, date: nil, description: nil, lmd: nil, lmt: nil, lmu: nil}

  def fixture(:posting) do
    {:ok, posting} = Accounts.create_posting(@create_attrs)
    posting
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all postings", %{conn: conn} do
      conn = get conn, posting_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create posting" do
    test "renders posting when data is valid", %{conn: conn} do
      conn = post conn, posting_path(conn, :create), posting: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, posting_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "amount" => "some amount",
        "date" => ~D[2010-04-17],
        "description" => "some description",
        "lmd" => ~D[2010-04-17],
        "lmt" => ~T[14:00:00.000000],
        "lmu" => "some lmu"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, posting_path(conn, :create), posting: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update posting" do
    setup [:create_posting]

    test "renders posting when data is valid", %{conn: conn, posting: %Posting{id: id} = posting} do
      conn = put conn, posting_path(conn, :update, posting), posting: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, posting_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "amount" => "some updated amount",
        "date" => ~D[2011-05-18],
        "description" => "some updated description",
        "lmd" => ~D[2011-05-18],
        "lmt" => ~T[15:01:01.000000],
        "lmu" => "some updated lmu"}
    end

    test "renders errors when data is invalid", %{conn: conn, posting: posting} do
      conn = put conn, posting_path(conn, :update, posting), posting: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete posting" do
    setup [:create_posting]

    test "deletes chosen posting", %{conn: conn, posting: posting} do
      conn = delete conn, posting_path(conn, :delete, posting)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, posting_path(conn, :show, posting)
      end
    end
  end

  defp create_posting(_) do
    posting = fixture(:posting)
    {:ok, posting: posting}
  end
end

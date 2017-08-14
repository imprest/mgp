defmodule MgpWeb.PdcController do
  use MgpWeb, :controller

  alias Mgp.Accounts
  alias Mgp.Accounts.Pdc

  action_fallback MgpWeb.FallbackController

  def index(conn, _params) do
    pdcs = Accounts.list_pdcs()
    render(conn, "index.json", pdcs: pdcs)
  end

  def create(conn, %{"pdc" => pdc_params}) do
    with {:ok, %Pdc{} = pdc} <- Accounts.create_pdc(pdc_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", pdc_path(conn, :show, pdc))
      |> render("show.json", pdc: pdc)
    end
  end

  def show(conn, %{"id" => id}) do
    pdc = Accounts.get_pdc!(id)
    render(conn, "show.json", pdc: pdc)
  end

  def update(conn, %{"id" => id, "pdc" => pdc_params}) do
    pdc = Accounts.get_pdc!(id)

    with {:ok, %Pdc{} = pdc} <- Accounts.update_pdc(pdc, pdc_params) do
      render(conn, "show.json", pdc: pdc)
    end
  end

  def delete(conn, %{"id" => id}) do
    pdc = Accounts.get_pdc!(id)
    with {:ok, %Pdc{}} <- Accounts.delete_pdc(pdc) do
      send_resp(conn, :no_content, "")
    end
  end
end

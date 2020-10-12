defmodule MgpWeb.CustomersLive do
  use MgpWeb, :live_view

  alias Mgp.Accounts
  alias Mgp.Utils
  alias Mgp.Sales

  @permitted_years ~w(2019 2018 2017 2016)

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       suggestions: [],
       id: nil,
       posting: nil,
       year: @permitted_years |> hd,
       years: @permitted_years
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    year =
      params
      |> param_or_first_permitted("year", @permitted_years)

    id = params["id"]

    posting =
      if id == nil or id == "" do
        nil
      else
        Accounts.postings(id, String.to_integer(year))
      end

    {:noreply, assign(socket, id: id, posting: posting, year: year)}
  end

  @impl true
  def handle_event("suggest", %{"search" => search}, socket) do
    length = String.length(search)

    if length >= 2 || length <= 12 do
      {:noreply, assign(socket, suggestions: Sales.get_customers(search))}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("submit", %{"search" => _}, socket), do: {:noreply, socket}

  @impl true
  def handle_event("select", %{"id" => customer_id, "value" => value}, socket) do
    {:noreply,
     push_patch(
       socket,
       to: Routes.live_path(socket, __MODULE__, id: customer_id)
     )}
  end

  @impl true
  def handle_event("year-change", %{"value" => year}, socket), do: year_change(socket, year)

  @impl true
  def handle_event("year-change", %{"key" => "ArrowUp", "value" => year}, socket),
    do: year_change(socket, year)

  @impl true
  def handle_event("year-change", %{"key" => "ArrowDown", "value" => year}, socket),
    do: year_change(socket, year)

  @impl true
  def handle_event("year-change", _key, socket), do: {:noreply, socket}

  defp year_change(socket, year) do
    if socket.assigns.year != year do
      if socket.assigns.id == nil do
        {:noreply, assign(socket, year: year)}
      else
        {:noreply,
         push_patch(
           socket,
           to: Routes.live_path(socket, __MODULE__, id: socket.assigns.id, year: year)
         )}
      end
    else
      {:noreply, socket}
    end
  end

  defp param_or_first_permitted(params, key, permitted) do
    value = params[key]
    if value in permitted, do: value, else: hd(permitted)
  end

  defp trim_id(id) do
    if String.starts_with?(id, "S") do
      id
    else
      {_, t} = String.split_at(id, 9)
      t
    end
  end
end

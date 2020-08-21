defmodule MgpWeb.CustomersLive do
  use MgpWeb, :live_view

  alias Mgp.Accounts
  alias Mgp.Utils

  @permitted_years ~w(2019 2018 2017 2016)
  @customers [
    %{id: "DANNI", description: "DANNI PHARMA"},
    %{id: "POKU", description: "POKU PHARMA"},
    %{id: "DAN/AX", description: "DANNI PHARMA - ANNEX"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket,
     temporary_assigns: [
       suggestions: @customers,
       id: nil,
       posting: nil,
       year: @permitted_years |> hd,
       years: @permitted_years
     ]}
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

  defp suggest(search) do
    Enum.filter(@customers, fn i ->
      i.description
      |> String.downcase()
      |> String.contains?(String.downcase(search))
    end)
  end

  @impl true
  def handle_event("suggest", %{"search" => search}, socket) do
    {:noreply, assign(socket, suggestions: suggest(search))}
  end

  @impl true
  def handle_event("year-change", %{"value" => year}, socket) do
    year_change(socket, year)
  end

  @impl true
  def handle_event("year-change", %{"key" => "ArrowUp", "value" => year}, socket) do
    year_change(socket, year)
  end

  @impl true
  def handle_event("year-change", %{"key" => "ArrowDown", "value" => year}, socket) do
    year_change(socket, year)
  end

  @impl true
  def handle_event("year-change", _key, socket), do: {:noreply, socket}

  defp year_change(socket, year) do
    {:noreply,
     push_patch(
       socket,
       to: Routes.live_path(socket, __MODULE__, id: "DAN/AX", year: year)
     )}
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

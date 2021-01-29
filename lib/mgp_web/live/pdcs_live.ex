defmodule MgpWeb.PdcsLive do
  use MgpWeb, :live_view

  alias Mgp.Fin
  alias Mgp.Utils

  @permitted_sort_orders ~w(asc desc)
  @permitted_sort_bys ~w(date id customer_id description cheque amount lmt)

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [pdcs: [], total: 0.00]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    sort_by =
      params
      |> param_or_first_permitted("sort_by", @permitted_sort_bys)
      |> String.to_atom()

    sort_order =
      params
      |> param_or_first_permitted("sort_order", @permitted_sort_orders)
      |> String.to_atom()

    sort_options = %{sort_by: sort_by, sort_order: sort_order}
    result = Fin.list_pdcs(sort_options)
    {:noreply, assign(socket, options: sort_options, total: result.total, pdcs: result.pdcs)}
  end

  defp sort_link(socket, text, sort_by, options) do
    text =
      if sort_by == options.sort_by do
        text <> emoji(options.sort_order)
      else
        text
      end

    live_patch(text,
      to:
        Routes.live_path(
          socket,
          __MODULE__,
          sort_by: sort_by,
          sort_order: toggle_sort_order(options.sort_order)
        )
    )
  end

  defp param_or_first_permitted(params, key, permitted) do
    value = params[key]
    if value in permitted, do: value, else: hd(permitted)
  end

  defp toggle_sort_order(:asc), do: :desc
  defp toggle_sort_order(:desc), do: :asc
  defp emoji(:desc), do: "⬆"
  defp emoji(:asc), do: "⬇"
end

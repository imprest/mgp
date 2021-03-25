defmodule MgpWeb.PageLive do
  use MgpWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_event("svelte-test", _, socket) do
    {:noreply, push_event(socket, "svelte", %{svelteID: "svelte-1", points: 100})}
  end

  @impl true
  def handle_event("text_clicked", _, socket) do
    {:noreply, push_event(socket, "text_clicked", %{points: 200})}
  end

  @impl true
  def handle_event("load_products", data, socket) do
    {:noreply,
     push_event(socket, "svelte", %{
       svelteID: data["svelteID"],
       products: Jason.Fragment.new(Mgp.Sales.products())
     })}
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    {:noreply, assign(socket, results: search(query), query: query)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    case search(query) do
      %{^query => vsn} ->
        {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "No dependencies found matching \"#{query}\"")
         |> assign(results: %{}, query: query)}
    end
  end

  defp search(query) do
    if not MgpWeb.Endpoint.config(:code_reloader) do
      raise "action disabled when not in development"
    end

    for {app, desc, vsn} <- Application.started_applications(),
        app = to_string(app),
        String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
        into: %{},
        do: {app, vsn}
  end
end

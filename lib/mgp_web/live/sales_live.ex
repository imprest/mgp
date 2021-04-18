defmodule MgpWeb.SalesLive do
  use MgpWeb, :live_view

  @impl true
  def render(assigns) do
    ~L'''
    <%= live_svelte_component "Sales", %{}, id: "sales" %>
    '''
  end

  @impl true
  def handle_event("get_daily_sales", %{"date" => date}, socket) do
    d = Date.from_iso8601!(date)

    {:noreply,
     push_event(socket, "get_daily_sales", %{
       sales: Jason.Fragment.new(Mgp.Sales.get_daily_sales(d))
     })}
  end

  @impl true
  def handle_event("get_monthly_sales", %{"year" => year, "month" => month}, socket) do
    {:noreply,
     push_event(socket, "get_monthly_sales", %{
       sales: Jason.Fragment.new(Mgp.Sales.get_monthly_sales(year, month))
     })}
  end

  @impl true
  def handle_event("get_yearly_sales", %{"year" => year}, socket) do
    {:noreply,
     push_event(socket, "get_yearly_sales", %{
       sales: Jason.Fragment.new(Mgp.Sales.get_yearly_sales(year))
     })}
  end
end

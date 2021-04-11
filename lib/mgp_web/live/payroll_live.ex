defmodule MgpWeb.PayrollLive do
  use MgpWeb, :live_view

  @impl true
  def render(assigns) do
    ~L'''
    <%= live_svelte_component "Payroll", %{}, id: "payroll" %>
    '''
  end

  @impl true
  def handle_event("get_monthly_payroll", %{"month" => month}, socket) do
    {:noreply,
     push_event(socket, "get_monthly_payroll", %{
       payroll: Mgp.Sync.ImportPayroll.import_month(month)
     })}
  end
end

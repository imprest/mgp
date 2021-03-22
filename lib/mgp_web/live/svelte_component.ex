defmodule MgpWeb.SvelteComponent do
  use MgpWeb, :live_component

  def render(assigns) do
    ~L"""
    <div
      id="<%= random_id(@name) %>"
      data-name="<%= @name %>"
      data-props="<%= json(@props) %>"
      phx-update="ignore"
      phx-hook="svelte-component">
    </div>
    """
  end

  defp json(props) do
    props
    |> Jason.encode()
    |> case do
      {:ok, message} ->
        message

      {:error, reason} ->
        IO.inspect(reason)
        ""
    end
  end

  def random_id(name) do
    "svelte-#{String.replace(name, " ", "-")}-"
    |> Kernel.<>(random_encoded_bytes())
    |> String.replace(["/", "+"], "-")
  end

  defp random_encoded_bytes do
    binary = <<
      System.system_time(:nanosecond)::64,
      :erlang.phash2({node(), self()})::16,
      :erlang.unique_integer()::16
    >>

    Base.url_encode64(binary)
  end
end

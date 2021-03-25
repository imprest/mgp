defmodule PhoenixLiveSvelte do
  import Phoenix.HTML
  import Phoenix.HTML.Tag

  def live_svelte_component(name, props \\ %{}, options \\ []) do
    html_escape([
      receiver_element(name, props, options)
    ])
  end

  defp receiver_element(name, props, options) do
    attr = Keyword.get(options, :receiver, [])
    tag = Keyword.get(options, :receiver_tag, :div)
    binding_prefix = Keyword.get(options, :binding_prefix, "phx-")

    default_attr = [
      id: Keyword.get(options, :id),
      data: [
        svelte_name: name,
        svelte_props: Jason.encode!(props)
      ],
      "#{binding_prefix}hook": "LiveSvelte",
      "#{binding_prefix}update": "ignore"
    ]

    content_tag(tag, "", Keyword.merge(default_attr, attr))
  end
end

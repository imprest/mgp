use Mix.Releases.Config,
  default_release: :mgp,
  default_environment: Mix.env()

environment :dev do
  set(dev_mode: true)
  set(include_erts: false)
  set(cookie: :dev)
end

environment :prod do
  set(include_erts: true)
  set(include_src: false)
  set(cookie: File.read!("config/cookie.txt") |> String.to_atom())
  set(vm_args: "rel/vm.args.eex")
end

release :mgp do
  set(version: current_version(:mgp))
end

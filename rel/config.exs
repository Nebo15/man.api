use Mix.Releases.Config,
  default_release: :default,
  default_environment: :default

environment :default do
  set pre_start_hook: "bin/hooks/pre-start.sh"
  set dev_mode: false
  set include_erts: false
  set include_src: false
  set overlays: [
    {:template, "rel/templates/vm.args.eex", "releases/<%= release_version %>/vm.args"}
  ]
end

release :man_api do
  set version: current_version(:man_api)
  set applications: [
    man: :permanent
  ]
end

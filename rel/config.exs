# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
use Mix.Releases.Config,
  default_release: :default,
  default_environment: :default

environment :default do
  set(dev_mode: false)
  set(include_erts: true)
  set(include_src: false)

  set(
    overlays: [
      {:template, "rel/templates/vm.args.eex", "releases/<%= release_version %>/vm.args"}
    ]
  )
end

release :man_api do
  set(pre_start_hooks: "bin/hooks/")
  set(version: current_version(:man_api))

  set(
    applications: [
      man_api: :permanent
    ]
  )

  set(config_providers: [ConfexConfigProvider])
end

use Mix.Releases.Config,
  default_release: :default,
  default_environment: :default

cookie = :sha256
|> :crypto.hash(System.get_env("ERLANG_COOKIE") || "5ytan2iIOAVJ84D2T8MWP87RgVo9PhvQ2jlcc3Zs/0fOod3AtUkTKjLBAKx+pJK2")
|> Base.encode64

environment :default do
  set pre_start_hook: "bin/hooks/pre-start.sh"
  set dev_mode: false
  set include_erts: false
  set include_src: false
  set cookie: cookie
end

release :printout do
  set version: current_version(:printout)
  set applications: [
    printout: :permanent
  ]
end

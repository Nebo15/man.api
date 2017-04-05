defmodule Printout.Web.Router do
  @moduledoc """
  The router provides a set of macros for generating routes
  that dispatch to specific controllers and actions.
  Those macros are named after HTTP verbs.

  More info at: https://hexdocs.pm/phoenix/Phoenix.Router.html
  """
  use Printout.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :put_secure_browser_headers
  end

  pipeline :eview do
    plug EView
  end

  scope "/", Printout.Web do
    pipe_through [:api, :eview]

    resources "/templates", TemplateController, except: [:new, :edit]
  end

  scope "/", Printout.Web do
    pipe_through :api

    post "/templates/:id/print", TemplateController, :print
  end
end

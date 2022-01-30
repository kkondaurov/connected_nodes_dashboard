# Based on https://github.com/phoenixframework/phoenix_live_dashboard/blob/master/test/test_helper.exs

Application.put_env(:phoenix_live_dashboard, ConnectedNodesDashboard.Endpoint,
  url: [host: "localhost", port: 4000],
  secret_key_base: "TTrifhpO9b3Va4iFwlup8mysUFFzYy+h3QSo1L44sQoNWIR71HH8rWMcmaQlj1Mg",
  live_view: [signing_salt: "ua8BFn6DZAMmVhdpB8u1DqFIGuS1wCKi"],
  render_errors: [view: ConnectedNodesDashboard.ErrorView],
  check_origin: false,
  pubsub_server: ConnectedNodesDashboard.PubSub
)

defmodule ConnectedNodesDashboard.ErrorView do
  use Phoenix.View, root: "test/templates"

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end

defmodule ConnectedNodesDashboard.Router do
  use Phoenix.Router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug(:fetch_session)
  end

  scope "/", ThisWontBeUsed, as: :this_wont_be_used do
    pipe_through(:browser)

    live_dashboard("/dashboard",
      additional_pages: [
        connected_nodes: {ConnectedNodesDashboard.Page, env_vars: [:FOO, :bar, "baz"]}
      ]
    )
  end
end

defmodule ConnectedNodesDashboard.Endpoint do
  use Phoenix.Endpoint, otp_app: :phoenix_live_dashboard

  plug(Plug.Session,
    store: :cookie,
    key: "_live_view_key",
    signing_salt: "LKtSWMBelSi9uXt/A7D0r0dtmKKo1c5b"
  )

  plug(ConnectedNodesDashboard.Router)
end

Application.ensure_all_started(:phoenix_live_dashboard)

Supervisor.start_link(
  [
    {Phoenix.PubSub, name: ConnectedNodesDashboard.PubSub, adapter: Phoenix.PubSub.PG2},
    ConnectedNodesDashboard.Endpoint
  ],
  strategy: :one_for_one
)

ExUnit.start()

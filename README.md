# ConnectedNodesDashboard

An additional page for [Phoenix LiveDashboard](https://github.com/phoenixframework/phoenix_live_dashboard/) with information about connected nodes.

For example, an app deployed to [fly.io](https://fly.io) as a cluster in 3 regions, one of which has a remote console running and an attached Livebook session, would look like this:

![Example screenshot](https://github.com/kkondaurov/connected_nodes_dashboard/raw/main/example.png)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `connected_nodes_dashboard` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:connected_nodes_dashboard, "~> 0.1.0"}
  ]
end
```

Add `ConnectedNodesDashboard.Page` to the list of additional LiveDashboard pages in your router:

```elixir
live_dashboard "/live_dashboard",
  # ...
  additional_pages: [
    connected_nodes: ConnectedNodesDashboard.Page
  ]
```

## Displaying Environmental Variables

You can also pass a list of environmental variables which values you'd like to see for each of the connected nodes.

```elixir
live_dashboard "/live_dashboard",
  # ...
  additional_pages: [
    connected_nodes: {ConnectedNodesDashboard.Page, env_vars: [:FOO, :BAR]}
  ]
```

Please note that since LiveDashboard table component requires fields to be atoms, `env_vars` elements should also be atoms - the library ignores string keys.

In the above example, `env_vars` is set up like this:

```elixir
live_dashboard "/live_dashboard",
  # ...
  additional_pages: [
    connected_nodes: {ConnectedNodesDashboard.Page, env_vars: [:FLY_REGION, :FLY_ALLOC_ID]}
  ]
```
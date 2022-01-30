# ConnectedNodesDashboard

An additional page for [Phoenix LiveDashboard](https://github.com/phoenixframework/phoenix_live_dashboard/) with information about connected nodes.

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

defmodule ConnectedNodesDashboard.Page do
  @moduledoc false
  use Phoenix.LiveDashboard.PageBuilder
  import Phoenix.LiveDashboard.Helpers
  require Logger

  @default_rpc_timeout 2_000

  @impl true
  def menu_link(_, _) do
    {:ok, "Connected Nodes"}
  end

  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign(:env_vars, env_vars(session))
      |> assign(:rpc_timeout, session[:rpc_timeout] || @default_rpc_timeout)

    {:ok, socket}
  end

  defp env_vars(session) do
    (session[:env_vars] || [])
    |> Enum.filter(&is_atom/1)
  end

  @impl true
  def render_page(assigns) do
    node = assigns.page.node
    env_vars = assigns.env_vars
    rpc_timeout = assigns.rpc_timeout

    case ConnectedNodesDashboard.RPC.collect_node_info(node, env_vars, rpc_timeout) do
      {:badrpc, {:EXIT, {:undef, _}}} ->
        Logger.error(
          "ConnectedNodesDashboard RPC call failed because module does not exist on node #{inspect(node)}"
        )

        render_rpc_undef_error(node)

      {:badrpc, reason} ->
        Logger.error(
          "ConnectedNodesDashboard RPC call to node #{inspect(node)} failed: #{inspect(reason)}"
        )

        render_rpc_call_error(node)

      {current_node_info, connected_nodes} ->
        render_node_info_page(assigns, current_node_info, connected_nodes)
    end
  end

  defp render_rpc_undef_error(node) do
    card(
      value:
        "Cannot retrieve information for node #{node} because it does not have #{__MODULE__} module. Please select a different node.",
      class: ["to-title", "bg-light"]
    )
  end

  defp render_rpc_call_error(node) do
    card(
      value: "Failed to collect information from node #{node}. Retrying...",
      class: ["to-title", "bg-danger", "text-white"]
    )
  end

  defp render_node_info_page(assigns, current_node_info, connected_nodes) do
    columns(
      components: [
        [
          render_current_node(current_node_info, assigns.env_vars),
          render_connected_nodes(assigns.page, connected_nodes, assigns.env_vars)
        ]
      ]
    )
  end

  defp render_current_node(current_node_info, env_vars) do
    field_rows =
      [:name, :hostname | env_vars]
      |> Enum.chunk_every(2)

    row(components: current_node_card_rows(current_node_info, field_rows))
  end

  defp current_node_card_rows(current_node_info, field_rows) do
    Enum.map(field_rows, fn field_row ->
      columns(components: build_current_node_row(current_node_info, field_row))
    end)
  end

  defp build_current_node_row(current_node_info, field_row) do
    field_row
    |> Enum.map(fn field ->
      card(
        inner_title: field,
        value: current_node_info[field]
      )
    end)
  end

  defp render_connected_nodes(page, connected_nodes, env_vars) do
    table(
      columns: connected_nodes_columns(env_vars),
      id: :nodes_table,
      row_attrs: &row_attrs/1,
      row_fetcher: &repackage_connected_nodes(&1, &2, connected_nodes),
      rows_name: "nodes",
      title: "Connected Nodes",
      default_sort_by: :rpc_call_time,
      limit: false,
      search: false,
      page: page
    )
  end

  defp repackage_connected_nodes(params, _node, connected_nodes) do
    %{sort_by: sort_by, sort_dir: sort_dir} = params

    connected_nodes =
      connected_nodes
      |> Enum.sort_by(& &1[sort_by], sort_dir)
      |> Enum.map(fn %{uptime: uptime} = node ->
        %{node | uptime: (uptime && format_uptime(uptime)) || nil}
      end)

    {connected_nodes, length(connected_nodes)}
  end

  defp connected_nodes_columns(env_vars) do
    basic_columns() ++ env_var_columns(env_vars)
  end

  defp basic_columns() do
    [
      %{
        field: :name,
        header: "Node"
      },
      %{
        field: :hostname,
        header: "Hostname"
      },
      %{
        field: :uptime,
        header: "Uptime"
      },
      %{
        field: :rpc_call_time,
        header: "RPC call time, ms",
        sortable: :asc
      }
    ]
  end

  defp env_var_columns(env_vars) do
    for env_var <- env_vars,
        do: %{
          field: env_var,
          header: env_var
        }
  end

  defp row_attrs(node) do
    [
      {"phx-value-info", "#{node[:name]}"},
      {"phx-page-loading", true}
    ]
  end
end

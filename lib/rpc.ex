defmodule ConnectedNodesDashboard.RPC do
  @moduledoc false

  require Logger

  @task_timeout_slack 100
  @default_rpc_timeout 2_000

  @spec collect_node_info(atom(), list(), integer()) :: {map(), [map()]} | {:badrpc, term()}
  def collect_node_info(node, env_vars \\ [], rpc_timeout \\ @default_rpc_timeout)

  def collect_node_info(node, env_vars, rpc_timeout) do
    env_vars = Enum.filter(env_vars, &is_atom/1)

    if node == Node.self() do
      collect_node_info_callback(env_vars, rpc_timeout)
    else
      :rpc.call(
        node,
        __MODULE__,
        :collect_node_info_callback,
        [env_vars, rpc_timeout],
        rpc_timeout
      )
    end
  end

  @spec collect_node_info_callback(list(), integer()) :: {map(), [map()]}
  def collect_node_info_callback(env_vars, rpc_timeout) do
    remote_nodes =
      Node.list(:connected)
      |> Enum.map(&Task.async(fn -> call_node_for_info(&1, env_vars, rpc_timeout) end))
      |> Task.await_many(rpc_timeout + @task_timeout_slack)
      |> Enum.reject(&(&1 == :badrpc))

    {node_info(env_vars), remote_nodes}
  end

  defp call_node_for_info(node, env_vars, rpc_timeout) do
    rpc_start = System.monotonic_time()
    raw_data = :rpc.call(node, __MODULE__, :node_info, [env_vars], rpc_timeout)
    rpc_end = System.monotonic_time()

    data =
      case raw_data do
        {:badrpc, reason} ->
          Logger.warn("#{__MODULE__} call to node #{inspect(node)} failed: #{inspect(reason)}")

          badrpc_node_info(node)

        raw_data ->
          raw_data
      end

    Map.put(data, :rpc_call_time, format_call_time(rpc_start, rpc_end))
  end

  def node_info(env_vars) do
    Enum.reduce(env_vars, basic_info(), fn env_var, acc ->
      Map.put_new(acc, env_var, System.get_env("#{env_var}"))
    end)
  end

  defp basic_info() do
    %{
      :name => Node.self(),
      :uptime => :erlang.statistics(:wall_clock) |> elem(0),
      :hostname => :inet.gethostname() |> elem(1)
    }
  end

  def badrpc_node_info(node) do
    %{
      :name => "#{node} (timeout)",
      :hostname => nil,
      :uptime => nil
    }
  end

  defp format_call_time(rpc_start, rpc_end) do
    System.convert_time_unit(rpc_end - rpc_start, :native, :millisecond)
  end
end

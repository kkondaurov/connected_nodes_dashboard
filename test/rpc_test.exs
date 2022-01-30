defmodule ConnectedNodesDashboard.RpcTest do
  use ExUnit.Case, async: false
  import ConnectedNodesDashboard.NodeTestHelper
  alias ConnectedNodesDashboard.RPC

  @host "127.0.0.1"

  describe "collect_node_info/3" do
    test "returns basic information about the current node" do
      current_node = Node.self()
      {:ok, hostname} = :inet.gethostname()

      assert {node_info, []} = RPC.collect_node_info(current_node)

      assert %{
               name: ^current_node,
               hostname: ^hostname,
               uptime: _
             } = node_info
    end

    test "returns environmental variables set for the current node" do
      System.put_env("foo", "FOO")
      System.put_env("bar", "BAR")
      System.put_env("baz", "BAZ")

      env_vars = [:foo, :bar, "baz"]
      assert {node_info, []} = RPC.collect_node_info(Node.self(), env_vars)

      assert %{
               foo: "FOO",
               bar: "BAR"
             } = node_info

      refute "BAZ" in Map.values(node_info)
    end
  end

  describe "collect_node_info/3 of a distributed node" do
    setup do
      switch_to_distributed_node("first", @host)
      on_exit(fn -> Node.stop() end)
    end

    test "called on the curent node, returns information about a connected node" do
      start_node("second", @host)
      second_node = :"second@#{@host}"
      {:ok, hostname} = :inet.gethostname()

      assert {_, [second_node_info]} = RPC.collect_node_info(:"first@#{@host}")

      assert %{
               name: ^second_node,
               hostname: ^hostname,
               uptime: _
             } = second_node_info
    end

    test "called on the curent node, returns metadata from a connected node" do
      System.put_env("foo", "FOO")

      start_node("second", @host)
      second_node = :"second@#{@host}"

      :rpc.call(second_node, System, :put_env, ["second_foo", "SECOND_FOO"])
      :rpc.call(second_node, System, :put_env, ["second_bar", "second_bar"])
      :rpc.call(second_node, System, :put_env, ["second_baz", "second_baz"])

      env_vars = [:second_foo, :second_bar, "second_baz"]
      assert {_, [second_node_info]} = RPC.collect_node_info(:"first@#{@host}", env_vars)

      assert %{
               second_foo: "SECOND_FOO",
               second_bar: "second_bar"
             } = second_node_info

      refute "second_baz" in Map.values(second_node_info)
      refute "FOO" in Map.values(second_node_info)
    end

    test "called on a connected node, returns basic info about it" do
      start_node("second", @host)
      second_node = :"second@#{@host}"
      {:ok, hostname} = :inet.gethostname()

      assert {second_node_info, [_]} = RPC.collect_node_info(second_node)

      assert %{
               name: ^second_node,
               hostname: ^hostname,
               uptime: _
             } = second_node_info
    end

    test "called on a connected node, returns basic info about the current one" do
      start_node("second", @host)
      second_node = :"second@#{@host}"
      {:ok, hostname} = :inet.gethostname()
      current_node = Node.self()

      assert {_, [current_node_info]} = RPC.collect_node_info(second_node)

      assert %{
               name: ^current_node,
               hostname: ^hostname,
               uptime: _
             } = current_node_info
    end
  end
end

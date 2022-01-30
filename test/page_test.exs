defmodule ConnectedNodesDashboard.PageTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  import ConnectedNodesDashboard.NodeTestHelper

  @endpoint ConnectedNodesDashboard.Endpoint

  @host "127.0.0.1"

  test "menu_link/2" do
    assert {:ok, "Connected Nodes"} = ConnectedNodesDashboard.Page.menu_link(%{}, %{})
  end

  describe "Connected Nodes page" do
    test "displays basic blocks" do
      {:ok, _live, rendered} = live(build_conn(), "/dashboard/connected_nodes")
      assert rendered =~ "#{Node.self()}"
      assert rendered =~ "Connected Nodes"
    end

    test "displays cards for env vars passed as atoms" do
      {:ok, _live, rendered} = live(build_conn(), "/dashboard/connected_nodes")
      assert rendered =~ "FOO"
      assert rendered =~ "bar"

      refute rendered =~ "baz"
    end
  end

  describe "Connected Nodes page of a distributed node" do
    setup do
      switch_to_distributed_node("first", @host)
      on_exit(fn -> Node.stop() end)
    end

    test "displays current node name" do
      {:ok, _live, rendered} = live(build_conn(), "/dashboard/connected_nodes")
      assert rendered =~ "first@#{@host}"
    end

    test "displays name of a connected node" do
      start_node("second", @host)
      {:ok, _live, rendered} = live(build_conn(), "/dashboard/connected_nodes")
      assert rendered =~ "second@#{@host}"
    end
  end
end

defmodule ConnectedNodesDashboard.NodeTestHelper do
  # Based on https://gist.github.com/beardedeagle/dc72f25fb561780f902d5dbf354a582d

  @cookie :foobar

  def switch_to_distributed_node(name, host) do
    node_name = String.to_atom("#{name}@#{host}")
    {:ok, _pid} = Node.start(node_name, :longnames)
    Node.set_cookie(@cookie)
    allow_fetch_code(host)
  end

  defp allow_fetch_code(host) do
    :erl_boot_server.start([])
    {:ok, ipv4} = :inet.parse_ipv4_address(to_charlist(host))
    :erl_boot_server.add_slave(ipv4)
  end

  def start_node(name, host) do
    node_name = String.to_atom(name)
    {:ok, node} = :slave.start(to_charlist("#{host}"), node_name, inet_loader_args(host))
    :rpc.call(node, :code, :add_paths, [:code.get_path()])
    Node.connect(node)
  end

  defp inet_loader_args(host) do
    '-loader inet -hosts #{host} -connect_all false -setcookie #{@cookie}'
  end
end


defmodule Servy.HttpServer do
  def start(port) when is_integer(port) and port > 1023 do
    {:ok, listen_socket} = :gen_tcp.listen(port, [
      :binary,
      packet: 0,
      active: false,
      reuseaddr: true,
      # By default, the backlog queue can hold 5 pending connection
      backlog: 50
    ])

    IO.puts "\n🎧 Listening for connection requests on port #{port}...\n"

    accept_loop(listen_socket)
  end

  def start(), do: start(8080)

  def accept_loop(listen_socket) do
    IO.puts "⏳ Waiting to accept a client connection...\n"
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)

    IO.puts "⚡️ Connection accepted!\n"
    pid = spawn(Servy.HttpServer, :serve, [client_socket])
    :ok = :gen_tcp.controlling_process(client_socket, pid)
    IO.puts "𐅬 Process #{Kernel.inspect(pid)} spawned\n"
    accept_loop(listen_socket)
  end

  def serve(client_socket) do
    client_socket
    |> read_request
    |> generate_response
    |> write_response(client_socket)
  end

  def read_request(client_socket) do
    case :gen_tcp.recv(client_socket, 0) do
      {:ok, request} -> request
      {:error, _closed} -> close_connection(client_socket)
    end
  end

  def generate_response(request) do
    Servy.Handler.handle(request)
  end

  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)

    close_connection(client_socket)
  end

  def close_connection(socket) do
    :gen_tcp.close(socket)
  end
end



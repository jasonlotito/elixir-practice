defmodule Servy.GenericServer do

  def start(callback_module, initial_state, name) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    Process.register pid, name
    pid
  end

  def call(pid, message) do
    send pid, {:call, self(), message}

    receive do {:response, response} -> response end
  end

  def cast(pid, message) do
    send pid, {:cast, message}
  end

  def listen_loop(state, callback_module) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call message, state
        send sender, {:response, response}
        listen_loop(new_state, callback_module)
      {:cast, message } ->
        new_state = callback_module.handle_cast message, state
        listen_loop(new_state, callback_module)
      unexpected ->
        IO.puts "Unexpected message: #{inspect unexpected}"
        listen_loop(state, callback_module)
    end
  end
end

defmodule Servy.PledgeServer do
  alias Servy.GenericServer

  @name __MODULE__
  @default_state %{total: 0, recent_pledges: []}

  #  Client API

  def start() do
    GenericServer.start(__MODULE__, @default_state, @name)
  end


  def stop() do
    GenericServer.cast @name, :shutdown
  end

  def create_pledge(name, amount) do
    GenericServer.call @name, {:create_pledge, name, amount}
  end

  def get_total do
    GenericServer.call @name, :total_pledges
  end

  def clear do
    GenericServer.cast @name, :clear
  end

  def recent_pledges do
    GenericServer.call @name, :recent_pledges
  end

  # Server Callbacks

  def handle_cast(:clear, _state) do
    @default_state
  end

  def handle_cast(:shutdown, _state) do
    exit :shutdown
  end

  def handle_call(:total_pledges, state) do
    {state.total, state}
  end

  def handle_call(:recent_pledges, state) do
    {state.recent_pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    new_state = %{
      total: state.total + amount,
      recent_pledges: [ {name, amount} | Enum.take(state.recent_pledges, 2) ]
    }
    {id, new_state}
  end

  defp send_pledge_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}" }
  end
end

alias Servy.PledgeServer

PledgeServer.start()
IO.puts "\nNow creating pledges"
IO.inspect PledgeServer.create_pledge  "larry", 10
IO.inspect PledgeServer.create_pledge "moe", 20
IO.inspect PledgeServer.create_pledge "curly", 30
IO.inspect PledgeServer.create_pledge "daisy", 40
IO.inspect PledgeServer.create_pledge "grace", 50
IO.inspect PledgeServer.create_pledge "grace", 50
IO.inspect PledgeServer.create_pledge "grace", 50

IO.inspect PledgeServer.recent_pledges()
IO.inspect PledgeServer.get_total()

PledgeServer.clear()
IO.puts "Cleared server"
IO.inspect PledgeServer.create_pledge "grace", 50
IO.inspect PledgeServer.create_pledge "grace", 50
IO.inspect PledgeServer.recent_pledges()
IO.inspect PledgeServer.get_total()
PledgeServer.stop()
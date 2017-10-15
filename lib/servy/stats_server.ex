defmodule Servy.StatsServer do

  alias Servy.GenericServer
  @name __MODULE__

  @doc """
  Starts the Stats Server with default values
  """
  def start(initial_state \\[]) do
    GenericServer.start(__MODULE__, initial_state, @name)
  end

  def track(method, path, status) do
    GenericServer.cast @name, {:track, method, path, status}
  end

  def stop() do
    GenericServer.cast @name, :shutdown
  end

  def get_stats do
    GenericServer.call @name, :get_stats
  end

  def handle_cast({:track, method, path, status}, state) do
    {method, path, status, 1}
    |> compact(state)
    |> IO.inspect
  end

  def handle_cast(:shutdown, _state) do
    exit :shutdown
  end

  def handle_call(:get_stats, state) do
    {state, state}
  end

  defp compact({method, path, status, count}, state) do
    case Enum.find_index(state, fn(stat) -> is_same_stat(stat, {method, path, status}) end) do
      index when is_number(index) ->
        {{_m, _p, _s, scount}, state} = List.pop_at state, index
        [ {method, path, status, scount + count } | state ]
      nil -> [ {method, path, status, count} | state ]
    end
  end

  defp is_same_stat({smethod, spath, sstatus, _scount}, {method, path, status}) do
    smethod == method and spath == path and sstatus == status
  end
end

Servy.StatsServer.start()
Servy.StatsServer.track("GET", "/foo", 200)
Servy.StatsServer.track("GET", "/foo", 200)
Servy.StatsServer.track("GET", "/foo", 200)
Servy.StatsServer.track("GET", "/bar", 200)
Servy.StatsServer.track("GET", "/bar", 200)
Servy.StatsServer.track("GET", "/bar", 200)
Servy.StatsServer.track("GET", "/bar", 200)
IO.inspect Servy.StatsServer.get_stats
Servy.StatsServer.stop()
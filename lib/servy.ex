defmodule Servy  do
  def main(args \\[8000]) do
    IO.inspect self()
    {port, _args} = List.pop_at(args, 0)
    Servy.PledgeServer.start()
    Servy.StatsServer.start()
    Servy.HttpServer.start(String.to_integer(port))
  end
end

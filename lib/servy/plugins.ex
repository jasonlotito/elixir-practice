defmodule Servy.Plugins do

  alias Servy.Conv
  alias Servy.StatsServer

  def track(%Conv{} = conv) do
    StatsServer.track( conv.method, conv.path, conv.response_code )
    conv
  end

  def log(%Conv{} = conv) do
#    IO.inspect conv
    conv
  end

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{} = conv), do: conv
end
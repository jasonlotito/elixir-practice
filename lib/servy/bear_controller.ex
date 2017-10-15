defmodule Servy.BearController do

  import Servy.View, only: [render: 3]

  alias Servy.Conv
  alias Servy.Wildthings
  alias Servy.Bear

  def index(%Conv{} = conv) do
    bears = Wildthings.list_bears()
            |> Enum.sort(&Bear.order_asc_by_name/2)
    render(conv, "index.eex", [bears: bears])
  end

  def show(%Conv{} = conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    render(conv, "show.eex", [bear: bear])
  end

  def create(%Conv{} = conv, %{"name" => name, "type" => type}) do
    %{conv | response_code: 201, resp_body: "Created a #{type} bear named #{name}."}
  end
end
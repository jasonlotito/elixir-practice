defmodule Servy.Api.BearController do

  def index(conv) do
    json = Servy.Wildthings.list_bears()
      |> Poison.encode!

    %{conv | response_code: 200, resp_body: json, resp_content_type: "application/json"}
  end

end
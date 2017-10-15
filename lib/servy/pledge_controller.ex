defmodule Servy.PledgeController do
  def create(conv, %{"name" => name, "amount" => amount}) do
    # Sends the pledge to the external service and caches it
    Servy.PledgeServer.create_pledge(name, String.to_integer(amount))

    %{ conv | response_code: 201 }
  end

  def create(conv, _vargs) do
    %{ conv | response_code: 400, resp_body: "Bad request." }
  end

  def index(conv) do
    # Gets the recent pledges from the cache
    pledges = Servy.PledgeServer.recent_pledges()

    %{ conv | response_code: 200, resp_body: (inspect pledges) }
  end

  def total_pledges(conv) do
    total_pledged = Servy.PledgeServer.get_total()
    %{ conv | response_code: 200, resp_body: (inspect total_pledged) }
  end
end

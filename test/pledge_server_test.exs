defmodule PledgeServerTest do
  use ExUnit.Case, async: false
  doctest Servy.PledgeServer

  alias Servy.PledgeServer

  test "Server totals correctly" do
    PledgeServer.create_pledge("Jason", 100)
    PledgeServer.create_pledge("Jason", 100)
    PledgeServer.create_pledge("Jason", 100)
    PledgeServer.create_pledge("Jason", 100)
    PledgeServer.create_pledge("Jason", 100)
    assert 500 == PledgeServer.get_total()

    PledgeServer.create_pledge("Jason", 100)
    PledgeServer.create_pledge("Jason", 200)
    PledgeServer.create_pledge("Jason", 300)
    PledgeServer.create_pledge("Jason", 400)
    PledgeServer.create_pledge("Jason", 500)

    assert [{"Jason", 500},{"Jason", 400},{"Jason", 300} ] == PledgeServer.recent_pledges()
  end
end
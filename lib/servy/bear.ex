defmodule Servy.Bear do
  defstruct id: nil, name: "", type: "", hibernating: false

  alias Servy.Bear

  @doc """
  Let's us know if the passed in bear is a Grizzly

  ## Example
  ```
  iex> Servy.Bear.is_grizzly(%{type: "Grizzly"})
  true
  iex> Servy.Bear.is_grizzly(%{type: "Is not a grizzly"})
  false
  ```
  """
  def is_grizzly(bear) do
    bear.type == "Grizzly"
  end

  @doc """
  Alphabetically sorts names

  ## Example
  ```
  iex> Servy.Bear.order_asc_by_name(%Servy.Bear{name: "Alpha"}, %Servy.Bear{name: "Zoot"})
  true
  iex> Servy.Bear.order_asc_by_name(%Servy.Bear{name: "Zoot"}, %Servy.Bear{name: "Alpha"})
  false
  ```
  """
  def order_asc_by_name(%Bear{name: fname}, %Bear{name: sname}) do
    fname <= sname
  end
end
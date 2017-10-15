defmodule Servy.View do

  alias Servy.Conv

  @template_path Path.expand("templates", File.cwd!)

  def render(%Conv{} = conv, template, bindings \\ []) do
    content = @template_path
              |> Path.join(template)
              |> EEx.eval_file(bindings)
    %{conv | response_code: 200, resp_body: content}
  end

end
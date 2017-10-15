defmodule Servy.Conv do
  defstruct method: "",
            response_code: 200,
            resp_content_type: "text/html",
            resp_body: "",
            path: "",
            params: %{},
            headers: %{}

  def full_status(%Servy.Conv{} = conv) do
    "#{conv.response_code} #{status_reason(conv.response_code)}"
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end

end
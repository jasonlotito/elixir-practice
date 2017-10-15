defmodule Servy.Parser do

  alias Servy.Conv

  @doc """
  Parses an HTTP request

  ## Example
  ```
  iex> req = "GET /foo HTTP/1.1\\r\\nFoo: foo\\r\\nBar: wut\\r\\nX-Baz: Baz\\r\\nContent-Length: 11\\r\\nContent-Type: application/x-www-form-urlencoded\\r\\n\\r\\nvar1=1&var2=2"
  iex> Servy.Parser.parse(req)
  %Servy.Conv{headers: %{
                "Bar" => "wut",
                "Content-Length" => "11",
                "Content-Type" => "application/x-www-form-urlencoded",
                "Foo" => "foo",
                "X-Baz" => "Baz"
              },
              method: "GET",
              params: %{"var1" => "1", "var2" => "2"},
              path: "/foo",
              resp_body: "",
              response_code: 200}
  ```

  If the header is malformed, we simply set it as both a key and value.

  This tests passing a header string: ```Bar:```

  ```
  iex> req = "GET /foo HTTP/1.1\\r\\nFoo: foo\\r\\nBar:\\r\\nX-Baz: Baz\\r\\nContent-Length: 11\\r\\nContent-Type: application/x-www-form-urlencoded\\r\\n\\r\\nvar1=1&var2=2"
  iex> Servy.Parser.parse(req)
  %Servy.Conv{headers: %{
              "Bar" => "Bar:",
              "Content-Length" => "11",
              "Content-Type" => "application/x-www-form-urlencoded",
              "Foo" => "foo",
              "X-Baz" => "Baz"
            },
            method: "GET",
            params: %{"var1" => "1", "var2" => "2"},
            path: "/foo",
            resp_body: "",
            response_code: 200}
  ```

  This tests parsing a header string: ```Bar```

  ```
  iex> req = "GET /foo HTTP/1.1\\r\\nFoo: foo\\r\\nBar\\r\\nX-Baz: Baz\\r\\nContent-Length: 11\\r\\nContent-Type: application/x-www-form-urlencoded\\r\\n\\r\\nvar1=1&var2=2"
  iex> Servy.Parser.parse(req)
  %Servy.Conv{headers: %{
              "Bar" => "Bar",
              "Content-Length" => "11",
              "Content-Type" => "application/x-www-form-urlencoded",
              "Foo" => "foo",
              "X-Baz" => "Baz"
            },
            method: "GET",
            params: %{"var1" => "1", "var2" => "2"},
            path: "/foo",
            resp_body: "",
            response_code: 200}
  ```

  This tests parsing arguments in the URL.  Note, in this case, ```var1``` is set in both the path and body.  However, the body should override the path.

  ```
  iex> req = "POST /foo?var1=THIS_IS_WRONG&bar=2 HTTP/1.1\\r\\nFoo: foo\\r\\nBar\\r\\nX-Baz: Baz\\r\\nContent-Length: 11\\r\\nContent-Type: application/x-www-form-urlencoded\\r\\n\\r\\nvar1=1&var2=2"
  iex> Servy.Parser.parse(req)
  %Servy.Conv{headers: %{
              "Bar" => "Bar",
              "Content-Length" => "11",
              "Content-Type" => "application/x-www-form-urlencoded",
              "Foo" => "foo",
              "X-Baz" => "Baz"
            },
            method: "POST",
            params: %{"bar" => "2", "var1" => "1", "var2" => "2"},
            path: "/foo",
            resp_body: "",
            response_code: 200}
  ```
  """
  def parse(request) do
    [top, params_string] = String.split(request, "\r\n\r\n")
    [request_line | header_lines] = String.split(top, "\r\n")
    [method, path, _] = String.split(request_line)
    [path, args] = case String.split(path, "?") do
      [path, args] -> [ path, args ]
      [path] -> [ path, "" ]
    end
    headers = parse_headers(header_lines, %{})
    params = parse_params(headers["Content-Type"], params_string)
    args = parse_params("application/x-www-form-urlencoded", args)

    %Conv{
      method: method,
      path: path,
      params: Map.merge(args, params),
      headers: headers
    }
  end

  @doc """
  Parses params in the form of `key1=value&key2=value2`

  ## Examples
  ```
  iex> params_string = "key1=value&key2=value2"
  iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
  %{"key1" => "value", "key2" => "value2"}
  iex> Servy.Parser.parse_params("multipart/form-data", params_string)
  %{}
  ```
  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim |> URI.decode_query
  end

  def parse_params(_, _), do: %{}

  @doc """
  Parsers headers

  ## Example
  ```
  iex> header_lines = ["A: 1", "B: 2"]
  iex> Servy.Parser.parse_headers(header_lines, %{})
  %{"A" => "1", "B" => "2"}
  ```

  ```
  iex> header_lines = ["A: 1", "B: 2", "Foo"]
  iex> Servy.Parser.parse_headers(header_lines, %{})
  %{"A" => "1", "B" => "2", "Foo" => "Foo"}
  ```

  ```
  iex> header_lines = ["A: 1", "B: 2", "Foo:"]
  iex> Servy.Parser.parse_headers(header_lines, %{})
  %{"A" => "1", "B" => "2", "Foo" => "Foo:"}
  ```

  ```
  iex> header_lines = ["A: 1", "B: 2", "Foo: "]
  iex> Servy.Parser.parse_headers(header_lines, %{})
  %{"A" => "1", "B" => "2", "Foo" => "Foo:"}
  ```
  """
  def parse_headers([head | tail], headers) do
    headers = case String.split(String.trim(head), ": ") do
      [key, value] -> Map.put(headers, key, String.trim(value))
      [key] -> Map.put(headers, String.trim_trailing(key,":"), String.trim(key))
    end
    parse_headers(tail, headers)
  end

  def parse_headers([], headers),do: headers
end
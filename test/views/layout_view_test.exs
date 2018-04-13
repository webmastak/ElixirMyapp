defmodule Myapp.LayoutViewTest do
  use Myapp.ConnCase, async: true

  def locale_list do
    Application.get_env(:myapp, :locales)
  end

  def locale_path(conn, lng) do
    conn.path_info
    |> tl
    |> Enum.join("/")
    |> String.replace_prefix("", "/#{lng}/")
  end  

end

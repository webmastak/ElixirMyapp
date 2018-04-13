defmodule Myapp.LayoutView do
  use Myapp.Web, :view

  def locale_list do
    Application.get_env(:myapp, :locales)
  end

  def locale_path(conn, lng) do
    conn.path_info
    |> tl
    |> Enum.join("/")
    |> String.replace_prefix("", "/#{lng}/")
  end
  
  def current_user(conn) do
    Plug.Conn.get_session(conn, :current_user)
  end
end

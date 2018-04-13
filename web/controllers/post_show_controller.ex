defmodule Myapp.PostShowController do
  use Myapp.Web, :controller
  alias Myapp.Post

  def index(conn, _params) do
    posts = Repo.all(from p in Post, limit: 5, order_by: [desc: :inserted_at], preload: [:user])
    render(conn, "index.html", posts: posts)
  end

  def show(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)
    render(conn, "show.html", post: post)
  end

end
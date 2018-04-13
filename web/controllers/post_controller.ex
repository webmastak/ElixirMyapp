defmodule Myapp.PostController do
  use Myapp.Web, :controller
  alias Myapp.Post
  plug :assign_user
  plug :authorize_user when action in [:new, :create, :update, :edit, :delete]

  def index(conn, %{"user_id" => _user_id}) do
    conn = assign_user(conn, nil)
    if conn.assigns[:user] do
      posts = Repo.all(assoc(conn.assigns[:user], :posts)) |> Repo.preload(:user)
      render(conn, "index.html", posts: posts)
    else
      conn
    end
  end

#  def index(conn, _params) do
#    posts = Repo.all(from p in Post,
#                       limit: 5,
#                       order_by: [desc: :inserted_at],
#                       preload: [:user])
#    render(conn, "index.html", posts: posts)
#  end

  def new(conn, _params) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:posts)
      |> Post.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params, "locale" => locale}) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:posts)
      |> Post.changeset(post_params)
    case Repo.insert(changeset) do
      {:ok, _post} ->
        conn
        |> put_flash(:info, gettext "Post created successfully.")
        |> redirect(to: user_post_path(conn, :index, locale, conn.assigns[:user]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Repo.get!(assoc(conn.assigns[:user], :posts), id)
    render(conn, "show.html", post: post)
  end

  def edit(conn, %{"id" => id}) do
    post = Repo.get!(assoc(conn.assigns[:user], :posts), id)
    changeset = Post.changeset(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params, "locale" => locale}) do
    post = Repo.get!(assoc(conn.assigns[:user], :posts), id)
    changeset = Post.changeset(post, post_params)
    case Repo.update(changeset) do
      {:ok, post} ->
        conn
        |> put_flash(:info, gettext "Post updated successfully.")
        |> redirect(to: user_post_path(conn, :show, locale, conn.assigns[:user], post))
      {:error, changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id, "locale" => locale}) do
    post = Repo.get!(assoc(conn.assigns[:user], :posts), id)
    # Здесь мы используем delete! (с восклицательным знаком), потому что мы ожидаем
    # что оно всегда будет работать (иначе возникнет ошибка).
    Repo.delete!(post)
    conn
    |> put_flash(:info, gettext "Post deleted successfully.")
    |> redirect(to: user_post_path(conn, :index, locale, conn.assigns[:user]))
  end


  # Private
  defp assign_user(conn, _opts) do
    case conn.params do
      %{"user_id" => user_id} ->
        case Repo.get(Myapp.User, user_id) do
          nil  -> invalid_user(conn, conn.params["locale"])
          user -> assign(conn, :user, user)
        end
      _ -> invalid_user(conn, conn.params["locale"])
    end
  end
  
  defp invalid_user(conn, locale) do
    conn
    |> put_flash(:error, dgettext("errors", "Invalid user!"))
    |> redirect(to: page_path(conn, :index, locale))
    |> halt
  end

  defp authorize_user(conn, _opts) do
    user = get_session(conn, :current_user)
    if user && Integer.to_string(user.id) == conn.params["user_id"] do
      conn
    else
      conn
      |> put_flash(:error, dgettext("errors", "You are not authorized to modify that post!"))
      |> redirect(to: page_path(conn, :index, conn.params["locale"]))
      |> halt()
    end
  end
end
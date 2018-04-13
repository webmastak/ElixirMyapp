defmodule Myapp.UserController do
  use Myapp.Web, :controller
  alias Myapp.User
  # alias Pxblog.Role

  # plug :authorize_admin when action in [:new, :create]
  plug :authorize_user when action in [:edit, :update, :delete]

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params, "locale" => locale}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext "User created successfully.")
        |> redirect(to: user_path(conn, :show, locale, user))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params, "locale" => locale}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext "User updated successfully.")
        |> redirect(to: user_path(conn, :show, locale, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id, "locale" => locale}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    conn
    |> put_flash(:info, gettext "User deleted successfully.")
    |> redirect(to: user_path(conn, :index, locale))
  end

  # Private
  defp authorize_user(conn, _) do
    user = get_session(conn, :current_user)
    # if user && (Integer.to_string(user.id) == conn.params["id"] || Myapp.RoleChecker.is_admin?(user)) do
    if user && (Integer.to_string(user.id) == conn.params["id"]) do
      conn
    else
      conn
      |> put_flash(:error, dgettext("errors", "You are not authorized to modify that user!"))
      |> redirect(to: page_path(conn, :index, conn.params["locale"]))
      |> halt()
    end
  end

  # defp authorize_admin(conn, _) do
  #   user = get_session(conn, :current_user)
  #   if user && Myapp.RoleChecker.is_admin?(user) do
  #     conn
  #   else
  #     conn
  #     |> put_flash(:error, dgettext("errors", "You are not authorized to create new users!"))
  #     |> redirect(to: page_path(conn, :index, conn.params["locale"]))
  #     |> halt()
  #   end
  # end
end

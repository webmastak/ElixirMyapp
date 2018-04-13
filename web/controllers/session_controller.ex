defmodule Myapp.SessionController do
  use Myapp.Web, :controller
  alias Myapp.User
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => %{"username" => username, "password" => password}, "locale" => locale})    
    when not is_nil(username) and not is_nil(password) do
      user = Repo.get_by(User, username: username)
      changeset = User.changeset(%User{}, %{username: username, password: password})   
      sign_in(user, password, conn, changeset, locale)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)
    failed_login(conn, changeset)
  end

  def delete(conn, %{"locale" => locale}) do
    conn
    |> delete_session(:current_user)
    |> put_flash(:info, gettext "Signed out successfully!")
    |> redirect(to: page_path(conn, :index, locale))
  end


  # Private
  defp failed_login(conn, changeset) do
    dummy_checkpw()
    conn
    |> put_session(:current_user, nil)  
    |> render("new.html", changeset: %{changeset | action: :insert})
    |> halt()
  end

  defp sign_in(user, _password, conn, changeset, _locale) when is_nil(user) do
    failed_login(conn, changeset)
  end

  defp sign_in(user, password, conn, changeset, locale) do
    if checkpw(password, user.password_digest) do
      conn
      |> put_session(:current_user, %{id: user.id, username: user.username})
      |> put_flash(:info, gettext "Sign in successful!")
      |> redirect(to: user_post_path(conn, :index, locale, user.id))
    else
      failed_login(conn, changeset)
    end
  end
end
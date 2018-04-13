defmodule Myapp.UserControllerTest do
  use Myapp.ConnCase

  alias Myapp.User
  @valid_attrs %{email: "some email", password_digest: "some password_digest", username: "some username"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn, "locale" => locale}} do
    conn = get conn, user_path(conn, :index, locale)
    assert html_response(conn, 200) =~ "Listing users"
  end

  test "renders form for new resources", %{conn: conn, "locale" => locale}} do
    conn = get conn, user_path(conn, :new, locale)
    assert html_response(conn, 200) =~ "New user"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, "locale" => locale}} do
    conn = post conn, user_path(conn, :create, locale), user: @valid_attrs
    user = Repo.get_by!(User, @valid_attrs)
    assert redirected_to(conn) == user_path(conn, :show, user.id)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, "locale" => locale}} do
    conn = post conn, user_path(conn, :create, locale), user: @invalid_attrs
    assert html_response(conn, 200) =~ "New user"
  end

  test "shows chosen resource", %{conn: conn, "locale" => locale}} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :show, locale, user)
    assert html_response(conn, 200) =~ "Show user"
  end

  test "renders page not found when id is nonexistent", %{conn: conn, "locale" => locale}} do
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, locale, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn, "locale" => locale}} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :edit, locale, user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, "locale" => locale}} do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, locale, user), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :show, locale, user)
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, "locale" => locale}} do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, locale, user), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "deletes chosen resource", %{conn: conn, "locale" => locale}} do
    user = Repo.insert! %User{}
    conn = delete conn, user_path(conn, :delete, locale, user)
    assert redirected_to(conn) == user_path(conn, :index, locale)
    refute Repo.get(User, user.id)
  end
end

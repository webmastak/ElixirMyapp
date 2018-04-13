defmodule Myapp.PostControllerTest do
  use Myapp.ConnCase

  alias Myapp.Post
  @valid_attrs %{body: "some body", title: "some title"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn, "locale" => locale} do
    conn = get conn, post_path(conn, :index, locale)
    assert html_response(conn, 200) =~ "Listing posts"
  end

  test "renders form for new resources", %{conn: conn, "locale" => locale} do
    conn = get conn, post_path(conn, :new, locale)
    assert html_response(conn, 200) =~ "New post"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, "locale" => locale} do
    conn = post conn, post_path(conn, :create, locale), post: @valid_attrs
    post = Repo.get_by!(Post, @valid_attrs)
    assert redirected_to(conn) == post_path(conn, :show, locale, post.id)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, "locale" => locale} do
    conn = post conn, post_path(conn, :create, locale), post: @invalid_attrs
    assert html_response(conn, 200) =~ "New post"
  end

  test "shows chosen resource", %{conn: conn, "locale" => locale} do
    post = Repo.insert! %Post{}
    conn = get conn, post_path(conn, :show, locale, post)
    assert html_response(conn, 200) =~ "Show post"
  end

  test "renders page not found when id is nonexistent", %{conn: conn, "locale" => locale} do
    assert_error_sent 404, fn ->
      get conn, post_path(conn, :show, locale, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn, "locale" => locale} do
    post = Repo.insert! %Post{}
    conn = get conn, post_path(conn, :edit, locale, post)
    assert html_response(conn, 200) =~ "Edit post"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, "locale" => locale} do
    post = Repo.insert! %Post{}
    conn = put conn, post_path(conn, :update, locale, post), post: @valid_attrs
    assert redirected_to(conn) == post_path(conn, :show, locale, post)
    assert Repo.get_by(Post, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, "locale" => locale} do
    post = Repo.insert! %Post{}
    conn = put conn, post_path(conn, :update, locale, post), post: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit post"
  end

  test "deletes chosen resource", %{conn: conn, "locale" => locale} do
    post = Repo.insert! %Post{}
    conn = delete conn, post_path(conn, :delete, locale, post)
    assert redirected_to(conn) == post_path(conn, :index, locale)
    refute Repo.get(Post, post.id)
  end
end

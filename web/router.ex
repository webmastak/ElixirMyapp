defmodule Myapp.Router do
  use Myapp.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SetLocale, gettext: Myapp.Gettext, default_locale: "en", cookie_key: "project_locale"
    plug Myapp.CurrentUserPlug

  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Myapp do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :dummy
  end

  scope "/:locale", Myapp do
    pipe_through :browser # Use the default browser stack
    
    get "/", PageController, :index
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    
    resources "/users", UserController do
      resources "/posts", PostController
    end

#   resources "/posts", PostController, only: [:index]
    resources "/posts", PostShowController, only: [:index, :show]
  end  

  # Other scopes may use custom stacks.
  # scope "/api", Myapp do
  #   pipe_through :api
  # end
end

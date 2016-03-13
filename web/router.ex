defmodule Risen.Router do
  use Risen.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", Risen.Landing do
    pipe_through :browser

    get  "/", HomeController, :index
    get  "/signin", AccountController, :signin_get
    post "/signin", AccountController, :signin_post
  end

  scope "/a", Risen.Admin do
    pipe_through :browser

    get "/", IndexController, :index
  end

  scope "/e", Risen.Employer do
    pipe_through :browser

    get "/", IndexController, :show
  end

  scope "/s", Risen.Student do
    pipe_through :browser

    get   "/:school/register", RegisterController, :register_get
    post  "/:school/register", RegisterController, :register_post

    get   "/:school/register/profile", RegisterController, :profile_get
    post  "/:school/register/profile", RegisterController, :profile_post

    get   "/:id/edit", ProfileController, :edit_get
    patch "/:id/edit", ProfileController, :edit_patch
  end

end

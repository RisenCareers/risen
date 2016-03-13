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

  scope "/a", Risen.Admin, as: :admin do
    pipe_through :browser

    get   "/", IndexController, :index
    get   "/students", StudentsController, :index
    get   "/students/:id/edit", StudentsController, :edit_get
    patch "/students/:id/edit", StudentsController, :edit_patch
    get   "/batches", BatchesController, :index
    get   "/batches/:id", BatchesController, :show
  end

  scope "/e", Risen.Employer, as: :employer do
    pipe_through :browser

    get "/", IndexController, :show
  end

  scope "/s", Risen.Student, as: :student do
    pipe_through :browser

    get   "/:school/register", RegisterController, :register_get
    post  "/:school/register", RegisterController, :register_post

    get   "/:school/register/profile", RegisterController, :profile_get
    post  "/:school/register/profile", RegisterController, :profile_post

    get   "/:id/edit", ProfileController, :edit_get
    patch "/:id/edit", ProfileController, :edit_patch
  end

end

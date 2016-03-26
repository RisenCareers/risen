defmodule Risen.Router do
  use Risen.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
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

    get   "/", IndexController, :index

    get   "/register", RegisterController, :register_get
    post  "/register", RegisterController, :register_post

    get   "/:employer_slug/setup", RegisterController, :setup_get
    put   "/:employer_slug/setup", RegisterController, :setup_update

    get   "/:employer_slug/students", StudentsController, :index
    get   "/:employer_slug/students/:id", StudentsController, :show

    get   "/:employer_slug/batches/:id", BatchesController, :show

    get   "/:employer_slug/settings", SettingsController, :show
    patch "/:employer_slug/settings", SettingsController, :update
  end

  scope "/s", Risen.Student, as: :student do
    pipe_through :browser

    get   "/:school/register/account", RegisterController, :account
    post  "/:school/register/account", RegisterController, :account_create
    get   "/:school/register/setup", RegisterController, :setup
    post  "/:school/register/setup", RegisterController, :setup_create
    get   "/:school/register/done", RegisterController, :done

    get   "/:id/edit", ProfileController, :edit_get
    patch "/:id/edit", ProfileController, :edit_patch
  end

end

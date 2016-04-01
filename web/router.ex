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

    get  "/signout", AccountController, :signout_get
  end

  scope "/a", Risen.Admin, as: :admin do
    pipe_through :browser

    get   "/", IndexController, :index

    get   "/students", StudentsController, :index
    get   "/students/:id/edit", StudentsController, :edit_get
    patch "/students/:id/edit", StudentsController, :edit_patch

    get   "/employers", EmployersController, :index

    get   "/schools", SchoolsController, :index
    get   "/schools/new", SchoolsController, :new
    post  "/schools", SchoolsController, :create

    get   "/batches", BatchesController, :index
    get   "/batches/:id", BatchesController, :show
    patch "/batches/:id", BatchesController, :update
  end

  scope "/e", Risen.Employer, as: :employer do
    pipe_through :browser

    get   "/", IndexController, :index

    get   "/register", RegisterController, :new
    post  "/register", RegisterController, :create

    get   "/:employer_slug/setup", SetupController, :edit
    put   "/:employer_slug/setup", SetupController, :update

    get   "/:employer_slug/students", StudentsController, :index
    get   "/:employer_slug/students/:id", StudentsController, :show
    patch "/:employer_slug/students/:id", StudentsController, :update

    get   "/:employer_slug/settings", SettingsController, :show
    patch "/:employer_slug/settings", SettingsController, :update
  end

  scope "/s", Risen.Student, as: :student do
    pipe_through :browser

    get   "/:school_slug/register", RegisterController, :new
    post  "/:school_slug/register", RegisterController, :create

    get   "/:school_slug/:id/setup", SetupController, :edit
    patch "/:school_slug/:id/setup", SetupController, :update
    get   "/:school_slug/:id/done", SetupController, :done

    get   "/:id/edit", ProfileController, :edit_get
    patch "/:id/edit", ProfileController, :edit_patch
  end

end

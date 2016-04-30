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

    get   "/", HomeController, :index

    get   "/schools", SchoolsController, :index

    get   "/signin", AccountController, :signin_get
    post  "/signin", AccountController, :signin_post

    get   "/signout", AccountController, :signout_get
  end

  scope "/a", Risen.Admin, as: :admin do
    pipe_through :browser

    get   "/", IndexController, :index

    get   "/students", StudentsController, :index
    get   "/students/:id/edit", StudentsController, :edit
    patch "/students/:id/edit", StudentsController, :update

    get    "/employers", EmployersController, :index

    get    "/schools", SchoolsController, :index
    get    "/schools/new", SchoolsController, :new
    post   "/schools", SchoolsController, :create
    get    "/schools/:id/edit", SchoolsController, :edit
    patch  "/schools/:id", SchoolsController, :update
    delete "/schools/:id", SchoolsController, :delete

    get   "/batches", BatchesController, :index
    get   "/batches/:id", BatchesController, :show
    patch "/batches/:id", BatchesController, :update

    get    "/majors", MajorsController, :index
    get    "/majors/new", MajorsController, :new
    post   "/majors", MajorsController, :create
    get    "/majors/:id/edit", MajorsController, :edit
    patch  "/majors/:id", MajorsController, :update
    delete "/majors/:id", MajorsController, :delete
  end

  scope "/e", Risen.Employer, as: :employer do
    pipe_through :browser

    get   "/", IndexController, :index

    get   "/register", RegisterController, :new
    post  "/register", RegisterController, :create

    get   "/:employer_slug/setup", SetupController, :edit
    patch "/:employer_slug/setup", SetupController, :update

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

    get   "/:id/edit", ProfileController, :edit
    patch "/:id/edit", ProfileController, :update
  end

end

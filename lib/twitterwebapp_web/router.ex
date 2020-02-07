defmodule TwitterwebappWeb.Router do
  use TwitterwebappWeb, :router

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

  scope "/", TwitterwebappWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/simulate",SimulationController,:simulate
    resources "/users", UserController


  end

  # Other scopes may use custom stacks.
  # scope "/api", TwitterwebappWeb do
  #   pipe_through :api
  # end
end

defmodule Mse25Web.Router do
  use Mse25Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Mse25Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Mse25Web do
    pipe_through :browser

    get "/", PageController, :home

    get "/evenemang", PageController, :events
    get "/webblogg", PageController, :articles
    get "/delningar", PageController, :links

    # get "/kommande-evenemang.ics", EventController, :calendar
    # get "/event-map.js", EventController, :interactive_map
    # get "/prenumerera.xml", TimelineController, :feed

    get "/*path", ItemController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Mse25Web do
  #   pipe_through :api
  # end
end

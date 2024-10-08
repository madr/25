defmodule Mse25Web.Router do
  use Mse25Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :put_root_layout, html: {Mse25Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :scripts do
    plug :accepts, ["js"]
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Mse25Web do
    pipe_through :scripts

    get "/event-map.js", FeedController, :interactive_event_map
  end

  scope "/", Mse25Web do
    pipe_through :browser

    get "/", PageController, :home
    get "/evenemang", PageController, :events
    get "/webblogg", PageController, :articles
    get "/delningar", PageController, :links
    get "/sok", PageController, :search

    get "/prenumerera.xml", FeedController, :feed
    get "/albums.json", FeedController, :albums
    get "/events.json", FeedController, :events
    get "/kommande-evenemang.ics", FeedController, :calendar

    get "/*path", ItemController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Mse25Web do
  #   pipe_through :api
  # end
end

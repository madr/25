defmodule Mse25Web.PageController do
  use Mse25Web, :controller

  alias Logger.Backends.Console
  alias Mse25.Directus

  def home(conn, _params) do
    [most_recent_article, older_article] = Directus.get_articles!(limit: 2)
    recent_event = Directus.get_events!(limit: 1)
    upcoming_events = Directus.get_events!(limit: 1, upcoming: true)

    render(conn, :home,
      layout: false,
      recent_article: most_recent_article,
      older_article: older_article,
      recent_event: recent_event,
      upcoming: upcoming_events
    )
  end
end

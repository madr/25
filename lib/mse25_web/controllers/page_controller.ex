defmodule Mse25Web.PageController do
  use Mse25Web, :controller

  alias Mse25.Directus

  def home(conn, _params) do
    [most_recent_article, older_article] = Directus.get_articles!(limit: 2)
    recent_event = Directus.get_events!(limit: 1)
    upcoming_events = Directus.get_events!(limit: 1, upcoming: true)
    brutal_legends = Directus.get_albums!(limit: 1)

    render(conn, :home,
      page_title: "Anders Englöf Ytterström @ madr.se",
      layout: false,
      recent_article: most_recent_article,
      older_article: older_article,
      recent_event: recent_event,
      upcoming: upcoming_events,
      brutal_legends: brutal_legends
    )
  end

  def articles(conn, _params) do
    articles = Directus.get_articles!(limit: 9999) |> group_annually

    render(conn, :articles,
      page_title: "Webblogg",
      articles: articles
    )
  end

  defp group_annually(items) do
    items
    |> Enum.group_by(fn %{"slug" => slug} -> String.slice(slug, 0..3) end)
    |> Map.to_list()
    |> Enum.sort(fn {a, _a}, {b, _b} -> b < a end)
  end
end

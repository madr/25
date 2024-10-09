defmodule Mse25Web.PageController do
  use Mse25Web, :controller

  alias Mse25.Directus
  alias Mse25.Timeline

  @almost_infinity 9999

  def home(conn, _params) do
    [most_recent_article, older_article] = Directus.get_articles!(limit: 2)
    recent_event = Directus.get_events!(limit: 1)
    upcoming_events = Directus.get_events!(limit: 1, upcoming: true)
    brutal_legends = Directus.get_albums!(limit: 1)

    render(conn, :home,
      page_title: "Anders Englöf Ytterström",
      layout: false,
      recent_article: most_recent_article,
      older_article: older_article,
      recent_event: recent_event,
      upcoming: upcoming_events,
      brutal_legends: brutal_legends
    )
  end

  def search(conn, %{"q" => ""}) do
    redirect(conn, to: ~p"/")
  end

  def search(conn, %{"q" => query}) do
    {:ok, %{results: results, count: count}} = Timeline.search(query)

    scount =
      case count do
        0 -> "Inga"
        c -> to_string(c)
      end

    render(conn, :search,
      q: query,
      page_title: scount <> " sökresultat för \"" <> query <> "\"",
      results: results
    )
  end

  def search(conn, _params) do
    redirect(conn, to: ~p"/")
  end

  def articles(conn, params) do
    {articles, page_title} =
      case params do
        %{"q" => query_string} ->
          {Directus.get_articles!(limit: @almost_infinity, query: query_string),
           "Webblogg: \"#{query_string}\""}

        _ ->
          {Directus.get_articles!(limit: @almost_infinity), "Webblogg"}
      end

    render(conn, :articles,
      page_title: page_title,
      articles: group_annually(articles),
      q: params["q"],
      nosearch?: params["q"] == nil or params["q"] == ""
    )
  end

  def events(conn, params) do
    {_, %{"title" => title, "contents" => contents}} = Directus.get_page("evenemang")

    events =
      case params do
        %{"q" => query_string} ->
          Directus.get_events!(limit: @almost_infinity, query: query_string)

        _ ->
          Directus.get_events!(limit: @almost_infinity)
      end
      |> group_annually

    render(conn, :events,
      page_title: title,
      contents: Earmark.as_html!(contents),
      events: events,
      q: params["q"],
      nosearch?: params["q"] == nil or params["q"] == ""
    )
  end

  def links(conn, _params) do
    links = Directus.get_links!(limit: @almost_infinity) |> group_by_date

    render(conn, :links,
      page_title: "Delningar",
      links: links
    )
  end

  defp group_annually(items) do
    items
    |> Enum.group_by(fn %{"slug" => slug} -> String.slice(slug, 0..3) end)
    |> Map.to_list()
    |> Enum.sort(fn {a, _a}, {b, _b} -> b < a end)
  end

  defp group_by_date(items) do
    items
    |> Enum.group_by(fn %{"pubDate" => pub_date} -> pub_date end)
    |> Map.to_list()
    |> Enum.sort(fn {a, _a}, {b, _b} -> b < a end)
  end
end

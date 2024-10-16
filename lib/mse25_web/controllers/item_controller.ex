defmodule Mse25Web.ItemController do
  use Mse25Web, :controller
  alias Mse25.Directus
  alias Mse25.Timeline

  def index(conn, _params) do
    case conn.path_info |> fetch do
      {:ok, item_type, item_data} ->
        render(conn, item_type, assigns(item_type, item_data))

      {:not_found, message} ->
        render(conn, message)
    end
  end

  defp fetch([year, slug], :article) do
    case Directus.get_article(year <> "/" <> slug) do
      {:ok, response} -> {:ok, :article, response}
      _ -> fetch([year, slug], :link)
    end
  end

  defp fetch([year, slug], :link) do
    case Directus.get_link(year <> "/" <> slug) do
      {:ok, response} -> {:ok, :link, response}
      _ -> fetch([year, slug], :event)
    end
  end

  defp fetch([year, slug], :event) do
    case Directus.get_event(year <> "/" <> slug) do
      {:ok, response} -> {:ok, :event, response}
      not_found -> not_found
    end
  end

  defp fetch([_year, album_id], :album) do
    case Directus.get_album(album_id) do
      {:ok, response} -> {:ok, :album, response}
      not_found -> not_found
    end
  end

  defp fetch([year, "brutal-legend-" <> external_id]) do
    fetch([year, external_id], :album)
  end

  defp fetch([year, slug]) do
    fetch([year, slug], :article)
  end

  defp fetch([slug]) do
    case Integer.parse(slug) do
      :error ->
        case Directus.get_page(slug) do
          {:ok, response} -> {:ok, :page, response}
          error -> error
        end

      {year, _} ->
        case Timeline.annual(year) do
          {:ok, response} -> {:ok, :annual, response}
          error -> error
        end
    end
  end

  defp assigns(:annual, %{
         timeline: timeline,
         year: year,
         counts: counts
       }),
       do: [
         year: year,
         page_title: "Innehåll från " <> to_string(year),
         breadcrumbs: [{year, year}],
         timeline: timeline,
         brutal_legends_count: Map.get(counts, :albums, 0),
         article_count: Map.get(counts, :articles, 0),
         event_count: Map.get(counts, :events, 0),
         link_count: Map.get(counts, :links, 0)
       ]

  defp assigns(:article, %{
         "title" => heading,
         "contents" => contents,
         "pubDate" => published_at,
         "date_updated" => updated_at
       }) do
    year = String.slice(published_at, 0..3)

    [
      page_title: heading,
      breadcrumbs: [{"webblogg", "Webblogg"}, {year, year, ""}],
      heading: heading,
      contents: Earmark.as_html!(contents),
      published_at: published_at,
      updated_at:
        case updated_at do
          nil -> published_at
          ua -> String.slice(ua, 0..9)
        end,
      year: year
    ]
  end

  defp assigns(:event, %{
         "title" => heading,
         "contents" => contents,
         "started_at" => started_at,
         "ended_at" => ended_at,
         "lead" => lead,
         "poster" => poster,
         "bands" => bands,
         "mia" => mia,
         "category" => category
       }) do
    year = String.slice(started_at, 0..3)

    [
      page_title: heading,
      breadcrumbs: [{"evenemang", "Evenemang"}, {year, year, ""}],
      heading: heading,
      contents: Earmark.as_html!(contents),
      lead: lead,
      year: year,
      poster: poster,
      bands: bands,
      mia: mia,
      category: category,
      started_at: started_at,
      ended_at: ended_at
    ]
  end

  defp assigns(:link, %{
         "title" => heading,
         "contents" => contents,
         "pubDate" => published_at,
         "date_updated" => updated_at,
         "source" => url,
         "h1" => title
       }) do
    year = String.slice(published_at, 0..3)

    [
      page_title: heading,
      breadcrumbs: [{"delningar", "Delningar"}, {year, year, ""}],
      heading: heading,
      contents: Earmark.as_html!(contents),
      published_at: published_at,
      url: url,
      title: title,
      year: year,
      updated_at:
        case updated_at do
          nil -> published_at
          ua -> String.slice(ua, 0..9)
        end
    ]
  end

  defp assigns(:page, %{
         "title" => heading,
         "contents" => contents,
         "date_updated" => updated_at
       }) do
    [
      page_title: heading,
      breadcrumbs: [],
      heading: heading,
      contents: Earmark.as_html!(contents),
      updated_at: String.slice(updated_at, 0..9)
    ]
  end

  defp assigns(:album, %{
         "year" => year,
         "album" => album,
         "contents" => contents,
         "cover" => cover,
         "purchased_at" => purchased_at,
         "externalId" => count,
         "songs" => songs,
         "summary" => summary,
         "artist" => artist
       }) do
    purchase_year = String.slice(purchased_at, 0..3)

    [
      page_title: summary,
      breadcrumbs: [{purchase_year, purchase_year}],
      count: count,
      album: album,
      cover: cover,
      year: to_string(year),
      purchase_year: purchase_year,
      contents: Earmark.as_html!(contents),
      songs: Enum.map(songs, fn %{"title" => name} -> "\"" <> name <> "\"" end),
      artist: artist,
      summary: summary
    ]
  end
end

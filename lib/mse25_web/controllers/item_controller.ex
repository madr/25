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

  defp fetch([year, slug]) do
    fetch([year, slug], :article)
  end

  defp fetch([slug]) do
    case Integer.parse(slug) do
      {:error} ->
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
    [
      page_title: heading,
      heading: heading,
      contents: Earmark.as_html!(contents),
      published_at: published_at,
      updated_at:
        case updated_at do
          nil -> published_at
          ua -> String.slice(ua, 0..9)
        end,
      year: String.slice(published_at, 0..3)
    ]
  end

  defp assigns(:event, %{
         "title" => heading,
         "contents" => contents,
         "started_at" => started_at,
         "lead" => lead,
         "poster" => poster,
         "bands" => bands,
         "mia" => mia,
         "category" => category
       }) do
    [
      page_title: heading,
      heading: heading,
      contents: Earmark.as_html!(contents),
      lead: lead,
      year: String.slice(started_at, 0..3),
      poster: poster,
      bands: bands,
      mia: mia,
      category: category
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
    [
      page_title: heading,
      heading: heading,
      contents: Earmark.as_html!(contents),
      published_at: published_at,
      url: url,
      title: title,
      year: String.slice(published_at, 0..3),
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
      heading: heading,
      contents: Earmark.as_html!(contents),
      updated_at: String.slice(updated_at, 0..9)
    ]
  end
end

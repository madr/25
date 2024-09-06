defmodule Mse25Web.ItemController do
  use Mse25Web, :controller
  alias Mse25.Directus

  def index(conn, _params) do
    case conn.path_info |> fetch do
      {:ok, item_type, item_data} ->
        render(conn, item_type, assigns(item_type, item_data))

      {:not_found, message} ->
        render(conn, message)
    end
  end

  defp fetch([year, slug]) do
    case Directus.get_article(year <> "/" <> slug) do
      {:ok, response} -> {:ok, :article, response}
      not_found -> not_found
    end
  end

  defp fetch([slug]) do
    case Directus.get_page(slug) do
      {:ok, response} -> {:ok, :page, response}
      not_found -> not_found
    end
  end

  defp assigns(:article, %{
         "title" => heading,
         "contents" => contents,
         "pubDate" => published_at,
         "date_updated" => updated_at
       }) do
    [
      heading: heading,
      contents: Earmark.as_html!(contents),
      published_at: published_at,
      updated_at: updated_at
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
      updated_at: updated_at
    ]
  end
end

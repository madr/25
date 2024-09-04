defmodule Mse25.Directus do
  def get_page(slug) do
    get_item(:pages, slug)
  end

  def get_link(slug) do
    get_item(:links, slug)
  end

  def get_event(slug) do
    get_item(
      :events,
      slug,
      [
        "*",
        "location.*",
        "poster.filename_download",
        "poster.width",
        "poster.height",
        "bands.artists_id.name",
        "mia.artists_id.name"
      ]
      |> Enum.join(",")
    )
  end

  def get_article(slug) do
    get_item(:articles, slug)
  end

  def get_events(collection) do
    get("/" <> to_string(collection))
  end

  defp get_item(collection, slug, fields \\ "*") do
    case get(
           "/" <> to_string(collection) <> "?fields=" <> fields <> "&filter[slug][_eq]=" <> slug
         ) do
      [] -> {:not_found, slug}
      [item | _] -> {:ok, item}
    end
  end

  defp get(resource) do
    [base_url: base_url, token: token] = Application.fetch_env!(:mse25, :directus)
    req = Req.new(base_url: base_url <> "/items")

    Req.get!(req, url: resource, auth: {:bearer, token})
    |> payload
  end

  defp payload(%Req.Response{body: %{"data" => payload}}), do: payload
end

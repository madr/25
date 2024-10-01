defmodule Mse25.Directus do
  def get_article(slug) do
    get_item(:articles, slug)
  end

  def get_articles!(options \\ []) do
    params =
      [
        "sort=-pubDate",
        "fields=" <>
          Enum.join(
            [
              "slug",
              "title",
              "date_updated",
              "pubDate"
            ],
            ","
          )
      ]
      |> query_params_string(options, :articles)

    get("/articles?" <> params)
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
        "mia.artists_id.name",
        "location.name"
      ]
      |> Enum.join(",")
    )
  end

  def get_events!(options \\ []) do
    params =
      [
        "sort=-started_at",
        "fields=" <>
          Enum.join(
            [
              "title",
              "lead",
              "slug",
              "poster.filename_download",
              "poster.width",
              "poster.height",
              "bands.artists_id.name",
              "mia.artists_id.name"
            ],
            ","
          )
      ]
      |> query_params_string(options, :events)

    get("/events?" <> params)
  end

  def get_link(slug) do
    get_item(:links, slug)
  end

  def get_links!(options \\ []) do
    params =
      [
        "sort=-pubDate",
        "fields=" <>
          Enum.join(
            [
              "slug",
              "title",
              "date_updated",
              "pubDate",
              "h1",
              "source",
              "contents"
            ],
            ","
          )
      ]
      |> query_params_string(options, :links)

    get("/links?" <> params)
  end

  def get_page(slug) do
    get_item(:pages, slug)
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

    case Req.get!(req, url: resource, auth: {:bearer, token})
         |> payload do
      {:ok, payload} -> payload
      {:forbidden, message} -> message
    end
  end

  defp payload(%Req.Response{status: 200, body: %{"data" => payload}}), do: {:ok, payload}

  defp payload(%Req.Response{status: 401}), do: {:forbidden, "Invalid Directus credentials"}

  defp query_params_string(params, options, :events),
    do:
      params
      |> upcoming?(options)
      |> limit?(options)
      |> page?(options)
      |> Enum.join("&")

  defp query_params_string(params, options, _),
    do:
      params
      |> limit?(options)
      |> page?(options)
      |> Enum.join("&")

  defp limit?(params, opts) do
    case opts[:limit] do
      nil -> params
      lmt = _ -> ["limit=" <> to_string(lmt) | params]
    end
  end

  defp page?(params, opts) do
    case opts[:page] do
      nil -> params
      pg -> ["page=" <> to_string(pg) | params]
    end
  end

  defp upcoming?(params, opts) do
    case opts[:upcoming] do
      true -> ["filter[upcoming][_eq]=1" | params]
      _ -> ["filter[upcoming][_eq]=0" | params]
    end
  end
end

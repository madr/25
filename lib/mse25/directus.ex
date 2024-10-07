defmodule Mse25.Directus do
  @draft_filter "filter[status][_eq]=published"

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
      |> annual?(:articles, options)
      |> query_params_string(options, :articles)

    get("/articles?" <> params)
  end

  def get_album(externalId) do
    get_item(
      :albums,
      externalId,
      [
        "*",
        "songs.title",
        "songs.artist.name"
      ]
      |> Enum.join(",")
    )
  end

  def get_albums!(options \\ []) do
    params =
      [
        "sort=-purchased_at",
        "fields=" <>
          Enum.join(
            [
              "*",
              "songs.title",
              "songs.artist.name"
            ],
            ","
          )
      ]
      |> annual?(:albums, options)
      |> query_params_string(options, :brutal_legends)

    get("/albums?" <> params)
    |> Enum.map(fn m = %{"songs" => [%{"artist" => %{"name" => a}} | _], "purchased_at" => pa} ->
      m |> Map.put("artist", a) |> Map.put("purchase_year", String.slice(pa, 0..3))
    end)
  end

  def get_event(slug) do
    get_item(
      :events,
      slug,
      [
        "*",
        "location.*",
        "poster",
        "bands.artists_id.name",
        "mia.artists_id.name"
      ]
      |> Enum.join(",")
    )
  end

  def get_events!(options \\ []) do
    [sorting, filter] =
      case options[:upcoming] do
        true -> ["started_at", "1"]
        _ -> ["-started_at", "0"]
      end

    params =
      [
        "sort=" <> sorting,
        "filter[upcoming][_eq]=" <> filter,
        "fields=" <>
          Enum.join(
            [
              "title",
              "lead",
              "slug",
              "poster",
              "category",
              "started_at",
              "ended_at",
              "bands.artists_id.name",
              "mia.artists_id.name",
              "location.*"
            ],
            ","
          )
      ]
      |> annual?(:events, options)
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
      |> annual?(:links, options)
      |> query_params_string(options, :links)

    get("/links?" <> params)
  end

  def get_page(slug) do
    get_item(:pages, slug)
  end

  defp get_item(collection, externalId_or_slug, fields \\ "*")

  defp get_item(:albums, externalId, fields) do
    case get("/albums?fields=" <> fields <> "&filter[externalId][_eq]=" <> externalId) do
      [] -> {:not_found, externalId}
      [item | _] -> {:ok, item}
    end
  end

  defp get_item(collection, slug, fields) do
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

    resource =
      case String.contains?(resource, "?") do
        true -> resource <> "&" <> @draft_filter
        false -> resource <> "?" <> @draft_filter
      end

    case Req.get!(req, url: resource, auth: {:bearer, token})
         |> payload do
      {:ok, payload} -> payload
      {:forbidden, message} -> message
    end
  end

  defp payload(%Req.Response{status: 200, body: %{"data" => payload}}), do: {:ok, payload}

  defp payload(%Req.Response{status: 401}), do: {:forbidden, "Invalid Directus credentials"}

  defp query_params_string(params, options, _),
    do:
      params
      |> limit?(options)
      |> page?(options)
      |> query?(options)
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

  defp query?(params, opts) do
    case opts[:query] do
      nil -> params
      "" -> params
      pg -> ["filter[title][_icontains]=" <> String.replace(to_string(pg), " ", "%20") | params]
    end
  end

  defp annual?(params, type, opts) do
    case opts[:year] do
      nil ->
        params

      year ->
        year_filter(type, year, params)
    end
  end

  defp year_filter(:albums, year, params),
    do: [
      "filter[purchased_at][_gte]=" <> to_string(year) <> "-01-01",
      "filter[purchased_at][_lte]=" <> to_string(year) <> "-12-31"
      | params
    ]

  defp year_filter(:articles, year, params),
    do: [
      "filter[pubDate][_gte]=" <> to_string(year) <> "-01-01",
      "filter[pubDate][_lte]=" <> to_string(year) <> "-12-31"
      | params
    ]

  defp year_filter(:events, year, params),
    do: [
      "filter[started_at][_gte]=" <> to_string(year) <> "-01-01",
      "filter[ended_at][_lte]=" <> to_string(year) <> "-12-31"
      | params
    ]

  defp year_filter(:links, year, params),
    do: [
      "filter[pubDate][_gte]=" <> to_string(year) <> "-01-01",
      "filter[pubDate][_lte]=" <> to_string(year) <> "-12-31"
      | params
    ]
end

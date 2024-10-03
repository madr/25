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

  def get_albums!(options \\ []) do
    params =
      [
        "sort=-purchased_at",
        "fields=" <>
          Enum.join(
            [
              "purchased_at",
              "album",
              "year",
              "externalId",
              "cover.filename_download",
              "cover.width",
              "cover.height",
              "songs.title",
              "songs.artist.name"
            ],
            ","
          )
      ]
      |> query_params_string(options, :brutal_legends)

    get("/albums?" <> params)
    |> Enum.map(fn m = %{"songs" => [%{"artist" => %{"name" => a}} | _]} ->
      Map.put(m, "artist", a)
    end)
  end

  def get_album(externalId) do
    get_item(
      :albums,
      externalId,
      [
        "purchased_at",
        "album",
        "year",
        "youtubeId",
        "externalId",
        "cover.filename_download",
        "cover.width",
        "cover.height",
        "songs.title",
        "songs.artist.name"
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
      pg -> ["filter[title][_icontains]=" <> to_string(pg) | params]
    end
  end
end

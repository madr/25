defmodule Mse25Web.FeedController do
  use Mse25Web, :controller
  alias Mse25.Directus
  alias Mse25.Timeline
  plug :put_layout, false

  def feed(conn, _params) do
    {:ok, %{archive: items}} = Timeline.archive(20)

    text(
      conn |> put_resp_content_type("application/rss+xml"),
      items
      |> Mse25Web.FeedView.rss(conn.host)
    )
  end

  def calendar(conn, _) do
    text(
      conn |> put_resp_content_type("text/calendar"),
      Directus.get_events!(upcoming: true, limit: 9999)
      |> Enum.map(fn %{
                       "title" => title,
                       "lead" => lead,
                       "started_at" => starts_at,
                       "ended_at" => ends_at,
                       "location" => %{
                         "name" => venue,
                         "address" => region,
                         "position" => %{
                           "coordinates" => [lat, lng]
                         }
                       }
                     } ->
        %{
          title: title,
          lead: lead,
          region: region,
          venue: venue,
          latitude: lat,
          longitude: lng,
          all_day?: true,
          starts_at: String.replace(starts_at, "-", ""),
          ends_at: String.replace(ends_at, "-", "")
        }
      end)
      |> Mse25Web.FeedView.calendar()
    )
  end

  def albums(conn, _) do
    json(
      conn,
      Directus.get_albums!()
      |> Enum.map(fn %{
                       "album" => album,
                       "artist" => artist,
                       "externalId" => id,
                       "year" => year,
                       "purchased_at" => purchased_on,
                       "contents" => contents,
                       "songs" => songs
                     } ->
        {img, ""} = Integer.parse(id)

        %{
          id: id,
          img: to_string(img - 1) <> ".jpg",
          title: album,
          artist: artist,
          album: album,
          year: year,
          purchased_on: purchased_on,
          description: Earmark.as_html!(contents),
          songs: Enum.map(songs, fn %{"title" => song} -> song end)
        }
      end)
    )
  end

  def events(conn, _) do
    json(
      conn,
      Directus.get_events!(limit: 9999)
      |> Enum.map(fn %{
                       "title" => title,
                       "lead" => lead,
                       "poster" => img,
                       "started_at" => date,
                       "location" => %{
                         "name" => venue,
                         "address" => region,
                         "position" => %{
                           "coordinates" => [lat, lng]
                         }
                       },
                       "bands" => bands
                     } ->
        %{
          title: title,
          lead: lead,
          img: img,
          date: String.slice(date, 0..9),
          region: region,
          venue: venue,
          location: [lng, lat],
          bands: Enum.map(bands, fn %{"artists_id" => %{"name" => band}} -> band end)
        }
      end)
    )
  end

  def interactive_event_map(conn, _) do
    text(
      conn |> put_resp_content_type("text/javascript"),
      Directus.get_events!(limit: 9999)
      |> Enum.map(fn %{
                       "title" => title,
                       "started_at" => date,
                       "location" => %{
                         "name" => venue,
                         "address" => region,
                         "position" => %{
                           "coordinates" => [lat, lng]
                         }
                       }
                     } ->
        %{
          title: title,
          date: String.slice(date, 0..9),
          region: region,
          venue: venue,
          longitude: lng,
          latitude: lat
        }
      end)
      |> Mse25Web.FeedView.event_map()
    )
  end
end

defmodule Mse25Web.FeedController do
  use Mse25Web, :controller
  alias Mse25.Directus
  alias Mse25.Timeline

  def atom_feed() do
    :tbw
  end

  def upcoming_events_ics() do
    :tbw
  end

  def albums_json(conn, _) do
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

  def events_json(conn, _) do
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

  def event_map_js() do
    :tbw
  end
end

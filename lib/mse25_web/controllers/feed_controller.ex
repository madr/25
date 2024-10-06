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

  def albums_json(conn, _params) do
    json(
      conn,
      Directus.get_albums!()
      |> Enum.map(fn a ->
        {img, ""} = Integer.parse(a["externalId"])

        %{
          id: a["externalId"],
          img: to_string(img - 1) <> ".jpg",
          title: a["album"],
          artist: a["artist"],
          album: a["album"],
          year: a["year"],
          purchased_on: a["purchased_at"],
          description: Earmark.as_html!(a["contents"]),
          songs: Enum.map(a["songs"], fn %{"title" => song} -> song end)
        }
      end)
    )
  end

  def events_json() do
    :tbw
  end

  def event_map_js() do
    :tbw
  end
end

defmodule Mse25.Timeline do
  alias Mse25.Directus

  @almost_infinity 9999

  def archive(limit \\ @almost_infinity) do
    items =
      Task.await_many([
        Task.async(fn -> Directus.get_albums!() end),
        Task.async(fn -> Directus.get_articles!(limit: limit) end),
        Task.async(fn -> Directus.get_links!(limit: limit) end),
        Task.async(fn -> Directus.get_events!(limit: limit) end)
      ])

    archive =
      items
      |> List.flatten()
      |> Enum.sort_by(&sort_key/1)
      |> Enum.reverse()
      |> Enum.take(limit)
      |> Enum.map(&categorize/1)

    {:ok, %{archive: archive}}
  end

  def annual(year) do
    items =
      Task.await_many([
        Task.async(fn -> Directus.get_albums!(limit: @almost_infinity, year: year) end),
        Task.async(fn -> Directus.get_articles!(limit: @almost_infinity, year: year) end),
        Task.async(fn -> Directus.get_links!(limit: @almost_infinity, year: year) end),
        Task.async(fn -> Directus.get_events!(limit: @almost_infinity, year: year) end)
      ])

    counts =
      items
      |> Enum.reject(&Enum.empty?/1)
      |> Enum.map(fn [item | l] -> {item_key(item), Enum.count(l) + 1} end)
      |> Map.new()

    timeline =
      items
      |> List.flatten()
      |> Enum.sort_by(&sort_key/1)
      |> Enum.map(&categorize/1)
      |> Enum.group_by(fn item -> sort_key(item) |> String.slice(5..6) end)
      |> Enum.reverse()

    {:ok, %{year: year, timeline: timeline, counts: counts}}
  end

  def search(query) do
    items =
      Task.await_many([
        Task.async(fn -> Directus.get_articles!(limit: @almost_infinity, query: query) end),
        Task.async(fn -> Directus.get_links!(limit: @almost_infinity, query: query) end),
        Task.async(fn -> Directus.get_events!(limit: @almost_infinity, query: query) end)
      ])

    results =
      items
      |> List.flatten()
      |> Enum.sort_by(&sort_key/1)
      |> Enum.map(&categorize/1)
      # |> Enum.group_by(fn item -> sort_key(item) |> String.slice(5..6) end)
      |> Enum.reverse()

    {:ok, %{query: query, results: results, count: length(results)}}
  end

  defp sort_key(%{"pubDate" => date}), do: date
  defp sort_key(%{"started_at" => date}), do: date
  defp sort_key(%{"purchased_at" => date}), do: date

  defp item_key(%{"source" => _s, "pubDate" => _}), do: :links
  defp item_key(%{"pubDate" => _}), do: :articles
  defp item_key(%{"started_at" => _}), do: :events
  defp item_key(%{"purchased_at" => _}), do: :albums

  defp categorize(item) do
    Map.put(item, :t, item_key(item))
  end
end

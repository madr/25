defmodule Mse25Web.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use Mse25Web, :html

  embed_templates "page_html/*"

  def bandlist(bands) do
    bands
    |> Enum.map(fn b -> b["artists_id"]["name"] end)
    |> Enum.join(", ")
    |> String.replace(~r/, ([^,]+?)$/, " och \\1")
  end

  def hilights?(%{"bands" => bands, "category" => category}) do
    _festival_band?(bands, category)
  end

  def missed?(%{"mia" => bands, "category" => category}) do
    _festival_band?(bands, category)
  end

  def opening_acts?(%{"bands" => [_ | bands], "category" => "concert"}) do
    not Enum.empty?(bands)
  end

  def opening_acts?(_) do
    false
  end

  defp _festival_band?(bands, category)
       when category in ["cruise", "openairfestival", "cityfestival", "onedayfestival"] do
    not Enum.empty?(bands)
  end

  defp _festival_band?(_b, _c) do
    false
  end
end

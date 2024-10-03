defmodule Mse25.Utils do
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

  def _festival_band?(bands, category)
      when category in ["cruise", "openairfestival", "cityfestival", "onedayfestival"] do
    not Enum.empty?(bands)
  end

  def _festival_band?(_b, _c) do
    false
  end
end

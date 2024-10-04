defmodule Mse25Web.ItemHTML do
  use Mse25Web, :html
  import Mse25.EventHelpers

  embed_templates "item_html/*"

  def month_name("01"), do: "Januari"
  def month_name("02"), do: "Februari"
  def month_name("03"), do: "Mars"
  def month_name("04"), do: "April"
  def month_name("05"), do: "Maj"
  def month_name("06"), do: "Juni"
  def month_name("07"), do: "Juli"
  def month_name("08"), do: "Augusti"
  def month_name("09"), do: "September"
  def month_name("10"), do: "Oktober"
  def month_name("11"), do: "November"
  def month_name("12"), do: "December"

  def csl(items) do
    items
    |> Enum.join(", ")
    |> String.replace(~r/, ([^,]+?)$/, " och \\1")
  end
end

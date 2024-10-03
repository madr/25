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
end

defmodule Mse25Web.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use Mse25Web, :html
  import Mse25.EventHelpers

  embed_templates "page_html/*"
end

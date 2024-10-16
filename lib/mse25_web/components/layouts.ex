defmodule Mse25Web.Layouts do
  use Mse25Web, :html

  @url "https://madr.se"
  @list_views ["webblogg", "delningar", "evenemang"]

  embed_templates "layouts/*"

  def canonical(%{year: _, conn: %{path_info: path}}) do
    ~s"""
    <link rel="canonical" href="#{@url}/#{Enum.join(path, "/")}" />
    """
  end

  def canonical(_) do
    ""
  end

  def opengraph(%{heading: title, lead: lead, conn: %{path_info: path}}) do
    ~s"""
    <meta property="og:title" content="#{title}" />
    <meta property="og:description" content="#{lead}" />
    <meta property="og:type" content="event" />
    <meta property="og:url" content="#{@url}/#{Enum.join(path, "/")}" />
    <meta property="og:site_name" content="madr.se" />
    """
  end

  def opengraph(%{heading: title, conn: %{path_info: path}}) do
    ~s"""
    <meta property="og:title" content="#{title}" />
    <meta property="og:type" content="article" />
    <meta property="og:url" content="#{@url}/#{Enum.join(path, "/")}" />
    <meta property="og:site_name" content="madr.se" />
    """
  end

  def opengraph(%{page_title: title, conn: %{path_info: path}}) do
    ~s"""
    <meta property="og:title" content="#{title}" />
    <meta property="og:type" content="page" />
    <meta property="og:url" content="#{@url}/#{Enum.join(path, "/")}" />
    <meta property="og:site_name" content="madr.se" />
    """
  end

  def robots(%{conn: %{path_info: [first | []]}}) do
    case Integer.parse(first) do
      :error ->
        case Enum.member?(@list_views, first) do
          true ->
            ~s"""
            <meta name="robots" content="noindex,follow" />
            """

          false ->
            ~s"""
            <meta name="robots" content="index,follow" />
            """
        end

      {_i, _d} ->
        ~s"""
        <meta name="robots" content="noindex,follow" />
        """
    end
  end

  def robots(%{conn: %{path_info: [_p, _c]}}) do
    ~s"""
    <meta name="robots" content="index,follow" />
    """
  end

  def robots(_) do
    ~s"""
    <meta name="robots" content="noindex,follow" />
    """
  end

  def breadcrumbs(nodes) do
    breadcrumbs([], "", 1, nodes)
  end

  def breadcrumbs(seen, _path, _index, []) do
    Enum.reverse(seen)
  end

  def breadcrumbs(seen, path, index, [{slug, name} | nodes]) do
    breadcrumbs(
      [{index + 1, {path <> "/" <> to_string(slug), name}} | seen],
      path <> "/" <> to_string(slug),
      index + 1,
      nodes
    )
  end

  def breadcrumbs(seen, path, index, [{slug, name, custom_prefix} | nodes]) do
    breadcrumbs(
      [{index + 1, {custom_prefix <> "/" <> to_string(slug), name}} | seen],
      path <> "/" <> to_string(slug),
      index + 1,
      nodes
    )
  end

  def show_interactive_event_map?(assigns) do
    Map.has_key?(assigns, :events)
  end

  def show_footer?(%{heading: "Kolofon"}), do: false

  def show_footer?(%{}), do: true
end

defmodule Mse25Web.Layouts do
  use Mse25Web, :html

  @url "https://madr.se"

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
end

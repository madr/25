defmodule Mse25Web.FeedView do
  use Mse25Web, :html

  def rss(items, _host) do
    ~s"""
    <?xml version="1.0" encoding="utf-8"?>
    <rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:georss="http://www.georss.org/georss" xmlns:gml="http://www.opengis.net/gml">
        <channel>
            <title>madr.se</title>
            <description>The online home of Anders Englöf Ytterström, a metalhead and musician living and working in Borlänge, Sweden.</description>
            <language>sv</language>
            <link>https://madr.se/</link>
            <managingEditor>yttan@fastmail.se (Anders Englöf Ytterström)</managingEditor>
            <webMaster>yttan@fastmail.se (Anders Englöf Ytterström)</webMaster>
            <atom:link href="https://madr.se/prenumerera.xml" rel="self" type="application/rss+xml" />
            #{Enum.map(items, &rss_item/1)}
       </channel>
    </rss>
    """
  end

  def calendar(upcoming) do
    ~s"""
    BEGIN:VCALENDAR
    VERSION:2.0
    PRODID:-//https://madr.se//kommande-evenemang
    METHOD:PUBLISH
    #{upcoming |> Enum.map(fn %{title: title, starts_at: starts_at, ends_at: ends_at, longitude: longitude, latitude: latitude, lead: lead, venue: venue, region: region} -> ~s"""
      BEGIN:VEVENT
      UID:#{title}.#{starts_at}@madr.se
      DTSTAMP:#{starts_at}T000000
      DTSTART;VALUE=DATE:#{starts_at}
      DTEND;VALUE=DATE:#{ends_at}
      SUMMARY:#{title}
      DESCRIPTION:#{lead}
      LOCATION:#{venue}\, #{region}
      GEO:#{latitude};#{longitude}
      END:VEVENT
      """ end) |> Enum.join("")}END:VCALENDAR
    """
  end

  def event_map(markers) do
    ~s"""
    (function(g, document) {
      "use strict";

      const mapData = [
        #{markers |> Enum.map(fn %{date: date, latitude: latitude, longitude: longitude, title: title, region: region, venue: venue} -> ~s"""
      {
          location: [#{longitude}, #{latitude}],
          title: "#{title}",
          date: "#{date}",
          region: "#{region}",
          venue: "#{venue}"
      }
      """ end) |> Enum.join(",")}
      ]

      // insert Leaflet styles (<link>) to <head> and <script> to
      // bottom of <body>, and initiate the map when the assets have
      // loaded.
      var install = function() {
        var styles, leaflet;

        styles = document.createElement("link");
        styles.rel = "stylesheet";
        styles.href = "https://unpkg.com/leaflet@1.6.0/dist/leaflet.css";
        styles.integrity =
          "sha512-xwE/Az9zrjBIphAcBb3F6JVqxf46+CDLwfLMHloNu6KEQCAWi6HcDUbeOfBIptF7tcCzusKFjFw2yuvEpDL9wQ==";
        styles.crossOrigin = "";

        document.head.appendChild(styles);

        leaflet = document.createElement("script");
        leaflet.src = "https://unpkg.com/leaflet@1.6.0/dist/leaflet.js";
        leaflet.integrity =
          "sha512-gZwIG9x3wUXg2hdXF6+rVkLF/0Vi9U8D2Ntg4Ga5I5BZpVkVxlJWbSQtXPSiUTtC0TjtGOmxa1AJPuV0CPthew==";
        leaflet.crossOrigin = "";
        leaflet.async = true;
        leaflet.onload = function() {
          init(mapData);
        };

        document.body.appendChild(leaflet);
      };

      // inititate the map.
      // create markers for all events: one marker per venue. Display all
      // events on each venue through a popup by clicking on the marker.
      // set bounds to have all markers visible.
      var init = function(mapData) {
        var events,
          markers = {},
          L = g.L;

        if (L) {
          // create map and set initial bounds
          events = L.map("leaflet", { zoomDelta: 0.25, zoomSnap: 0 }).fitBounds(
            mapData.map(function(e) {
              return e.location;
            })
          );

          // use OpenStreetMap tile layer: it's free!
          L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png?{foo}", {
            foo: "bar",
            attribution:
              'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
          }).addTo(events);

          // group events by venue
          mapData.forEach(function(e) {
            if (markers[e.venue]) {
              markers[e.venue].events.push(e.date + " - " + e.title);
            } else {
              markers[e.venue] = {
                region: e.region,
                location: e.location,
                events: [e.date + " - " + e.title]
              };
            }
          });

          // create markers
          for (var m in markers) {
            if (markers.hasOwnProperty(m)) {
              L.marker(markers[m].location)
                .addTo(events)
                .bindPopup(
                  "<strong style='color: black'>" +
                    m +
                    ", " +
                    markers[m].region +
                    "</strong><br>" +
                    markers[m].events.join("<br>")
                );
            }
          }
        }
      };

      install();
    })(this, document);
    """
  end

  def pub_date(nil), do: ""
  def pub_date(%{"pubDate" => date}), do: format_rfc822(date)
  def pub_date(%{"started_at" => date}), do: format_rfc822(date)
  def pub_date(%{"purchased_at" => date}), do: format_rfc822(date)

  defp format_rfc822(date_time) when is_binary(date_time) do
    date_time
    |> Date.from_iso8601!()
    |> format_rfc822()
  end

  defp format_rfc822(date_time), do: Calendar.strftime(date_time, "%a, %d %b %Y 06:06:06 +0200")

  defp rss_item(%{
         :t => :articles,
         "title" => title,
         "contents" => contents,
         "slug" => slug,
         "pubDate" => date
       }) do
    ~s"""
    <item>
      <title>#{title}</title>
      <link>https://madr.se/#{slug}</link>
      <description>
        <![CDATA[#{Earmark.as_html!(contents)}]]>
      </description>
      <pubDate>#{format_rfc822(date)}</pubDate>
      <guid>https://madr.se/#{slug}</guid>
    </item>
    """
  end

  defp rss_item(%{
         :t => :events,
         "title" => title,
         "contents" => contents,
         "slug" => slug,
         "location" => %{
           "position" => %{
             "coordinates" => [lng, lat]
           }
         },
         "started_at" => date
       }) do
    ~s"""
    <item>
      <title>#{title}</title>
      <link>https://madr.se/#{slug}</link>
      <description>
        <![CDATA[#{Earmark.as_html!(contents)}]]>
      </description>
      <pubDate>#{format_rfc822(date)}</pubDate>
      <guid>https://madr.se/#{slug}</guid>
      <georss:where>
        <gml:Point>
          <gml:pos>#{to_string(lng) <> " " <> to_string(lat)}</gml:pos>
        </gml:Point>
      </georss:where>
    </item>
    """
  end

  defp rss_item(%{
         :t => :links,
         "title" => title,
         "contents" => contents,
         "slug" => slug,
         "pubDate" => date,
         "source" => link
       }) do
    ~s"""
    <item>
      <title>#{title}</title>
      <link>#{link}</link>
      <description>
        <![CDATA[#{Earmark.as_html!(contents)}]]>
      </description>
      <pubDate>#{format_rfc822(date)}</pubDate>
      <guid>https://madr.se/#{slug}</guid>
    </item>
    """
  end

  defp rss_item(%{
         :t => :albums,
         "summary" => summary,
         "contents" => contents,
         "purchased_at" => date,
         "externalId" => id,
         "purchase_year" => year
       }) do
    ~s"""
    <item>
      <title>#{summary}</title>
      <link>https://madr.se/#{year}/#{id}</link>
      <description>
        <![CDATA[#{Earmark.as_html!(contents)}]]>
      </description>
      <pubDate>#{format_rfc822(date)}</pubDate>
      <guid>https://madr.se/#{year}/#{id}</guid>
    </item>
    """
  end
end

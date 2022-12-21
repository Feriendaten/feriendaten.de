defmodule FeriendatenWeb.HeaderComponents do
  @moduledoc """
  Provides Header components for the FeriendatenWeb application.
  """
  use FeriendatenWeb, :html

  attr :twitter_card, :any, required: true

  def twitter_card(
        %{twitter_card: %{description: _description, title: _title, url: _url}} = assigns
      ) do
    ~H"""
    <meta name="twitter:card" content="summary" />
    <meta name="twitter:creator" content="@wintermeyer" />
    <meta name="twitter:title" content={@twitter_card[:title]} />
    <meta name="twitter:description" content={@twitter_card[:description]} />
    <meta name="twitter:image" content={@twitter_card[:image]} />

    <meta property="og:title" content={@twitter_card[:title]} />
    <meta property="og:description" content={@twitter_card[:description]} />
    <%= if @twitter_card[:image_16_9] do %>
      <meta property="og:image" content={@twitter_card[:image_16_9]} />
    <% else %>
      <meta property="og:image" content={@twitter_card[:image]} />
    <% end %>
    <meta property="og:url" content={@twitter_card[:url]} />
    <meta property="og:type" content="website" />
    """
  end

  def twitter_card(assigns) do
    ~H"""

    """
  end
end

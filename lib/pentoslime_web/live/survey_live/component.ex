defmodule PentoslimeWeb.SurveyLive.Component do
  use Phoenix.Component
  def hero(assigns) do
    ~H"""
    Assigns are: <%= inspect(assigns) %>
    <h2>
    content: <%= @content %>
    </h2>

    <h3>
    slot: <%= render_slot(@inner_block) %>
    </h3>
    """
  end
  def title(assigns) do
    ~H"""
    <h2> <%= @survey_title %> </h2>
    """
  end
end

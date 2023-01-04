defmodule PentoslimeWeb.SurveyLive.Component do
  use Phoenix.Component
  def hero(assigns) do
    ~H"""
    <h2>
    content: <%= @content %>
    </h2>

    <h3>
    slot: <%= render_slot(@inner_block) %>
    </h3>

    <h4>
    Assigns are: <%= inspect(assigns) %>
    </h4>
    """
  end
  def title(assigns) do
    ~H"""
    <h2> <%= @survey_title %> </h2>
    """
  end
end

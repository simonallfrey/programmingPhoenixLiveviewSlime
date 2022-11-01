defmodule PentoslimeWeb.PageController do
  use PentoslimeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

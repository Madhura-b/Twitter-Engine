defmodule TwitterwebappWeb.PageController do
  use TwitterwebappWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

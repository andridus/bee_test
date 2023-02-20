defmodule BeeTestWeb.PageController do
  use BeeTestWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

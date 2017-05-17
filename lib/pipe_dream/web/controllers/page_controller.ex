defmodule PipeDream.Web.PageController do
  use PipeDream.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

defmodule SkoolWeb.PageController do
  use SkoolWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: ~p"/tasks")
  end
end

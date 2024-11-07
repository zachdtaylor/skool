defmodule SkoolWeb.PageController do
  use SkoolWeb, :controller

  def home(conn, _params) do
    case conn.assigns.current_user do
      nil -> redirect(conn, to: ~p"/users/log_in")
      _user -> redirect(conn, to: ~p"/tasks")
    end
  end
end

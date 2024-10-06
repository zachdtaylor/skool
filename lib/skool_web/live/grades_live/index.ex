defmodule SkoolWeb.GradesLive.Index do
  use SkoolWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:active_tab, :grades)}
  end
end

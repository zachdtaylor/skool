defmodule SkoolWeb.GradesLive.Index do
  use SkoolWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col relative">
      <.header>
        Grades
      </.header>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:active_tab, :grades)}
  end
end

defmodule SkoolWeb.CourseLive.Show do
  use SkoolWeb, :live_view

  alias Skool.Courses

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    course = Courses.get_course!(id)

    {:noreply,
     socket
     |> assign(:page_title, course.name)
     |> assign(:course, course)}
  end
end

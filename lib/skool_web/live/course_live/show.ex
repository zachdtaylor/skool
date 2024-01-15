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
    assignments = Courses.load_assignments(course)

    {:noreply,
     socket
     |> assign(:page_title, course.name)
     |> assign(:course, course)
     |> stream(:assignments, assignments)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    assignment = Courses.get_assignment!(id)
    {:ok, _} = Courses.delete_assignment(assignment)

    {:noreply, stream_delete(socket, :assignments, assignment)}
  end
end

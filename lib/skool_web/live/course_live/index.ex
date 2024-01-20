defmodule SkoolWeb.CourseLive.Index do
  use SkoolWeb, :live_view

  alias Skool.Courses

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :courses, Courses.list_courses(socket.assigns.current_user))}
  end

  @impl true
  def handle_info({SkoolWeb.CourseLive.FormComponent, {:saved, course}}, socket) do
    {:noreply, stream_insert(socket, :courses, course)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    course = Courses.get_course!(id)
    {:ok, _} = Courses.delete_course(course)

    {:noreply, stream_delete(socket, :courses, course)}
  end
end

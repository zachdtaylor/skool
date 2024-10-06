defmodule SkoolWeb.CourseLive.Show do
  use SkoolWeb, :live_view

  alias Skool.Courses

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    course = id |> Courses.get_course!() |> Courses.preload_assignments()

    {:noreply,
     socket
     |> assign(:page_title, course.name)
     |> assign(:course, course)
     |> assign(:enrolled?, Courses.is_enrolled?(course, socket.assigns.current_user))
     |> stream(:assignments, course.assignments)
     |> assign(:active_tab, :courses)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    assignment = Courses.get_assignment!(id)
    {:ok, _} = Courses.delete_assignment(assignment)

    {:noreply, stream_delete(socket, :assignments, assignment)}
  end

  def handle_event("finalize", _params, socket) do
    socket.assigns.course
    |> Courses.update_course(%{finalized_at: DateTime.utc_now()})
    |> case do
      {:ok, course} ->
        {:noreply, assign(socket, course: course)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to finalize course")}
    end
  end

  def handle_event("enroll", _params, socket) do
    course_id = socket.assigns.course.id
    user_id = socket.assigns.current_user.id

    case Courses.enroll_user(course_id, user_id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "You have been enrolled in this course!")
         |> assign(:enrolled?, true)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to enroll in this course")}
    end
  end

  def handle_event("split_weights", _params, socket) do
    course = Courses.split_weights!(socket.assigns.course)
    {:noreply, stream(socket, :assignments, course.assignments)}
  end
end

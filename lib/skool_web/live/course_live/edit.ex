defmodule SkoolWeb.CourseLive.Edit do
  use SkoolWeb, :live_view

  alias Skool.Courses

  def mount(%{"id" => id}, _session, socket) do
    course = Courses.get_course!(id)
    changeset = Courses.change_course(course)

    {:ok,
     socket
     |> assign_course_name(course)
     |> assign_form(changeset)
     |> assign(:active_tab, :courses)}
  end

  def handle_event("save", %{"course" => course_params}, socket) do
    course = Courses.get_course!(course_params["id"])

    case Courses.update_course(course, course_params) do
      {:ok, _course} ->
        {:noreply, push_navigate(socket, to: ~p"/courses")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_course_name(socket, course) do
    assign(socket, course_name: course.name)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "course")

    assign(socket, form: form)
  end
end

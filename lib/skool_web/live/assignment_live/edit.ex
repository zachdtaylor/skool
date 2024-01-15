defmodule SkoolWeb.AssignmentLive.Edit do
  use SkoolWeb, :live_view

  alias Skool.Courses
  alias Skool.Courses.Assignment

  def mount(%{"course_id" => course_id, "assignment_id" => assignment_id}, _session, socket) do
    course = Courses.get_course!(course_id)
    assignment = Courses.get_assignment!(assignment_id)
    changeset = Courses.change_assignment(assignment)

    {:ok,
     socket
     |> assign(:page_title, "Edit Assignment")
     |> assign(:course, course)
     |> assign(:assignment, assignment)
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"assignment" => assignment_params}, socket) do
    assignment = Courses.get_assignment!(assignment_params["id"])

    case Courses.update_assignment(assignment, assignment_params) do
      {:ok, assignment} ->
        {:noreply,
         push_navigate(socket,
           to: ~p"/courses/#{assignment.course_id}/assignments/#{assignment.id}"
         )}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "assignment")

    assign(socket, form: form)
  end
end

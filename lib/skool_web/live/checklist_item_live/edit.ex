defmodule SkoolWeb.ChecklistItemLive.Edit do
  use SkoolWeb, :live_view

  alias Skool.Courses
  alias Skool.Courses.Assignment

  def mount(
        %{
          "course_id" => course_id,
          "assignment_id" => assignment_id,
          "checklist_item_id" => checklist_item_id
        },
        _session,
        socket
      ) do
    course = Courses.get_course!(course_id)
    assignment = Courses.get_assignment!(assignment_id)
    checklist_item = Courses.get_checklist_item!(checklist_item_id)
    changeset = Courses.change_checklist_item(checklist_item)

    {:ok,
     socket
     |> assign(:page_title, "Edit Checklist Item")
     |> assign(:course, course)
     |> assign(:assignment, assignment)
     |> assign_form(changeset)
     |> assign(:active_tab, :courses)}
  end

  def handle_event("save", %{"checklist_item" => checklist_item_params}, socket) do
    checklist_item = Courses.get_checklist_item!(checklist_item_params["id"])
    assignment = socket.assigns.assignment

    case Courses.update_checklist_item(checklist_item, checklist_item_params) do
      {:ok, _checklist_item} ->
        {:noreply,
         push_navigate(socket,
           to: ~p"/courses/#{assignment.course_id}/assignments/#{assignment.id}"
         )}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "checklist_item")

    assign(socket, form: form)
  end
end

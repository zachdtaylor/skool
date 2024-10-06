defmodule SkoolWeb.AssignmentLive.Show do
  use SkoolWeb, :live_view

  alias Skool.Courses

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:active_tab, :courses)}
  end

  @impl true
  def handle_params(%{"course_id" => course_id, "assignment_id" => assignment_id}, _, socket) do
    course = Courses.get_course!(course_id)
    assignment = Courses.get_assignment!(assignment_id)
    checklist_items = Courses.load_checklist_items(assignment) |> IO.inspect()

    {:noreply,
     socket
     |> assign(:page_title, assignment.title)
     |> assign(:assignment, assignment)
     |> assign(:course, course)
     |> stream(:checklist_items, checklist_items)}
  end
end

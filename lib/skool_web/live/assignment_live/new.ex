defmodule SkoolWeb.AssignmentLive.New do
  use SkoolWeb, :live_view

  alias Skool.Courses
  alias Skool.Courses.Assignment

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    course = Courses.get_course!(id)
    changeset = Courses.change_assignment(%Assignment{}, %{course_id: id})

    {:noreply,
     socket
     |> assign(:page_title, "New Assignment")
     |> assign(:course, course)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"assignment" => assignment_params}, socket) do
    changeset = Courses.change_assignment(%Assignment{}, assignment_params)
    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("create", %{"assignment" => assignment_params}, socket) do
    result = Courses.create_assignment(assignment_params)

    case result do
      {:ok, assignment} ->
        {:noreply, push_navigate(socket, to: ~p"/courses/#{assignment.course_id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "assignment")

    assign(socket, form: form)
  end
end

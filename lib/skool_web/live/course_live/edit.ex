defmodule SkoolWeb.CourseLive.Edit do
  use SkoolWeb, :live_view

  alias Skool.Courses

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col relative">
      <.header>
        Edit Course
        <:subtitle><%= @course_name %></:subtitle>
      </.header>
      <div class="p-4">
        <.form id="edit-course-form" for={@form} class="flex flex-col gap-4" phx-submit="save">
          <.input type="hidden" field={@form[:id]} />
          <.input type="hidden" field={@form[:created_by_id]} />
          <.input type="text" field={@form[:name]} label="Name" />
          <div class="grid grid-cols-2 gap-4">
            <.input type="date" field={@form[:start_date]} label="Start Date" />
            <.input type="date" field={@form[:end_date]} label="End Date" />
          </div>
          <.input type="textarea" field={@form[:description]} label="Description" />
        </.form>
      </div>
      <.footer>
        <:right>
          <.button type="submit" form="edit-course-form">Save</.button>
        </:right>
      </.footer>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    course = Courses.get_course!(id)
    changeset = Courses.change_course(course)

    {:ok,
     socket
     |> assign_course_name(course)
     |> assign_form(changeset)
     |> assign(:active_tab, :courses)}
  end

  @impl true
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

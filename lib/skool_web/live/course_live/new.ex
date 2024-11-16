defmodule SkoolWeb.CourseLive.New do
  use SkoolWeb, :live_view

  alias Skool.Courses
  alias Skool.Courses.Course

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative h-screen">
      <.header>
        Create a New Course
      </.header>
      <div class="p-4">
        <.form id="new-course-form" for={@form} class="flex flex-col gap-4" phx-submit="create">
          <.input type="hidden" field={@form[:created_by_id]} value={@current_user.id} />
          <.input type="text" field={@form[:name]} label="Name" />
          <div class="grid grid-cols-2 gap-4">
            <.input type="date" field={@form[:start_date]} label="Start Date" />
            <.input type="date" field={@form[:end_date]} label="End Date" />
          </div>
          <.input type="color" field={@form[:color]} label="Color" />
        </.form>
      </div>
      <.footer>
        <:right>
          <.button type="submit" form="new-course-form">Create</.button>
        </:right>
      </.footer>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    changeset = Courses.change_course(%Course{})
    {:ok, socket |> assign_form(changeset) |> assign(:active_tab, :courses)}
  end

  @impl true
  def handle_event("create", %{"course" => course}, socket) do
    case Courses.create_course(course) do
      {:ok, course} ->
        {:noreply, push_navigate(socket, to: ~p"/courses/#{course.id}/collaborators/invite")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "course")

    assign(socket, form: form)
  end
end

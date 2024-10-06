defmodule SkoolWeb.ChecklistItemLive.New do
  use SkoolWeb, :live_view

  alias Skool.Courses
  alias Skool.Courses.ChecklistItem

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col relative">
      <.header>
        New Checklist Item
        <:subtitle>
          <%= @course.name %> - <%= @assignment.title %>
        </:subtitle>
      </.header>
      <div class="p-4">
        <.form
          for={@form}
          id="new-checklist_item-form"
          class="flex flex-col gap-4"
          phx-change="validate"
          phx-submit="create"
        >
          <.input type="hidden" field={@form[:assignment_id]} value={@assignment.id} />
          <.input type="text" field={@form[:title]} label="Title" />
          <.input type="textarea" field={@form[:description]} label="Description" />
          <.input type="date" field={@form[:due_date]} label="Due Date" />
          <.input type="number" field={@form[:grade_weight]} label="Grade Weight" step="0.01" />
        </.form>
      </div>
      <.footer>
        <:left>
          <.link navigate={~p"/courses/#{@course}/assignments/#{@assignment}"}>
            <.button>Back to Assignment</.button>
          </.link>
        </:left>
        <:right>
          <.button type="submit" form="new-checklist_item-form">Save</.button>
        </:right>
      </.footer>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:active_tab, :courses)}
  end

  @impl true
  def handle_params(%{"course_id" => course_id, "assignment_id" => assignment_id}, _, socket) do
    course = Courses.get_course!(course_id)
    assignment = Courses.get_assignment!(assignment_id)
    changeset = Courses.change_checklist_item(%ChecklistItem{}, %{assignment_id: assignment_id})

    {:noreply,
     socket
     |> assign(:page_title, "New Checklist Item")
     |> assign(:assignment, assignment)
     |> assign(:course, course)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"checklist_item" => checklist_item_params}, socket) do
    changeset = Courses.change_checklist_item(%ChecklistItem{}, checklist_item_params)
    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("create", %{"checklist_item" => checklist_item_params}, socket) do
    case Courses.create_checklist_item(checklist_item_params) do
      {:ok, _checklist_item} ->
        {:noreply,
         push_navigate(socket,
           to: ~p"/courses/#{socket.assigns.course}/assignments/#{socket.assigns.assignment}"
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "checklist_item")

    assign(socket, form: form)
  end
end

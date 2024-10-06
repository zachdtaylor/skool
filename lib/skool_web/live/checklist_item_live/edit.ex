defmodule SkoolWeb.ChecklistItemLive.Edit do
  use SkoolWeb, :live_view

  alias Skool.Courses
  alias Skool.Courses.Assignment

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col relative">
      <.header>
        Edit Checklist Item
        <:subtitle><%= @assignment.title %> (<%= @course.name %>)</:subtitle>
      </.header>
      <div class="p-4">
        <.form id="edit-assignment-form" for={@form} class="flex flex-col gap-4" phx-submit="save">
          <.input type="hidden" field={@form[:id]} />
          <.input type="hidden" field={@form[:course_id]} />
          <.input type="text" field={@form[:title]} label="Title" />
          <.input
            type="select"
            field={@form[:kind]}
            label="Kind"
            options={Assignment.kinds()}
            prompt="Select Kind"
          />
          <%= if @form[:kind].value == :recurring do %>
            <div class="flex gap-2">
              <div class="flex-1">
                <.input type="date" field={@form[:start_date]} label="Start Date" />
              </div>
              <div class="flex-1">
                <.input type="date" field={@form[:end_date]} label="End Date" />
              </div>
            </div>
          <% else %>
            <.input type="date" field={@form[:due_date]} label="Due Date" />
          <% end %>
          <.input type="number" field={@form[:grade_weight]} label="Grade Weight" step="0.01" />
        </.form>
      </div>
      <.footer>
        <:left>
          <.button phx-hook="GoBack">Cancel</.button>
        </:left>
        <:right>
          <.button type="submit" form="edit-assignment-form">Save</.button>
        </:right>
      </.footer>
    </div>
    """
  end

  @impl true
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

  @impl true
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

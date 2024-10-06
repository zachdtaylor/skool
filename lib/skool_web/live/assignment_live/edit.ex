defmodule SkoolWeb.AssignmentLive.Edit do
  use SkoolWeb, :live_view

  import SkoolWeb.AssignmentLive.Helpers,
    only: [
      transform_repeats_on: 1,
      kinds: 0,
      repeats_every_units: 0,
      repeats_ons: 1,
      repeats_ons: 2
    ]

  alias Skool.Courses

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col relative">
      <.header>
        Edit Assignment
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
            options={kinds()}
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
            <%= if @form[:start_date].value do %>
              <div class="flex gap-2">
                <.input type="number" field={@form[:repeats_every]} label="Repeats Every" />
                <.input
                  type="select"
                  field={@form[:repeats_every_unit]}
                  label="Unit"
                  options={repeats_every_units()}
                />
              </div>
              <%= case @form[:repeats_every_unit].value do %>
                <% :week -> %>
                  <.input
                    type="select"
                    field={@form[:repeats_on]}
                    label="Repeats On"
                    options={repeats_ons(:week)}
                    multiple
                  />
                <% :month -> %>
                  <.input
                    type="select"
                    field={@form[:repeats_on]}
                    label="Repeats On"
                    options={repeats_ons(:month, @form[:start_date].value)}
                  />
                <% _ -> %>
              <% end %>
            <% end %>
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
  def mount(%{"course_id" => course_id, "assignment_id" => assignment_id}, _session, socket) do
    course = Courses.get_course!(course_id)
    assignment = Courses.get_assignment!(assignment_id)
    changeset = Courses.change_assignment(assignment)

    {:ok,
     socket
     |> assign(:page_title, "Edit Assignment")
     |> assign(:course, course)
     |> assign(:assignment, assignment)
     |> assign_form(changeset)
     |> assign(:active_tab, :courses)}
  end

  @impl true
  def handle_event("save", %{"assignment" => assignment_params}, socket) do
    assignment = Courses.get_assignment!(assignment_params["id"])

    case Courses.update_assignment(assignment, transform_repeats_on(assignment_params)) do
      {:ok, assignment} ->
        {:noreply,
         push_navigate(socket,
           to: ~p"/courses/#{assignment.course_id}"
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

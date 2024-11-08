defmodule SkoolWeb.AssignmentLive.Show do
  use SkoolWeb, :live_view

  alias Skool.Courses

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col relative">
      <.header>
        Assignment: <%= @assignment.title %>
        <:subtitle>
          <%= @course.name %>
        </:subtitle>
        <:actions>
          <.dropdown id="course-menu">
            <:options>
              <.link navigate={~p"/courses/#{@course}/assignments/#{@assignment}/edit"}>
                <.dropdown_option icon="hero-pencil-square" text="Edit assignment" />
              </.link>
            </:options>
          </.dropdown>
        </:actions>
      </.header>
      <div class="p-4">
        <p><%= @assignment.description %></p>
        <.list>
          <:item title="Kind">
            <%= @assignment.kind |> Atom.to_string() |> String.capitalize() %>
          </:item>
          <:item title="Start Date" if={@assignment.kind == :recurring}>
            <%= format_date(@assignment.start_date) %>
          </:item>
          <:item title="End Date" if={@assignment.kind == :recurring}>
            <%= format_date(@assignment.end_date) %>
          </:item>
          <:item title="Due Date" if={@assignment.kind != :recurring}>
            <%= format_date(@assignment.due_date) %>
          </:item>
          <:item title="Grade Weight">
            <%= format_percent(@assignment.grade_weight) %>
          </:item>
          <:item title="Repeats" if={@assignment.kind == :recurring}>
            <%= display_repeats(@assignment) %>
          </:item>
        </.list>
        <%= if @assignment.kind == :checklist do %>
          <div class="grid grid-cols-2 items-center my-8">
            <h1 class="text-md font-bold">Checklist Items</h1>
            <%= if is_nil(@course.finalized_at) do %>
              <.link
                navigate={~p"/courses/#{@course}/assignments/#{@assignment}/checklist_items/new"}
                class="justify-self-end"
              >
                <.button>New Checklist Item</.button>
              </.link>
            <% end %>
          </div>
          <.table id="checklist_items" rows={@streams.checklist_items}>
            <:col :let={{_id, item}} label="Title"><%= item.title %></:col>
            <:col :let={{_id, item}} label="Due"><%= format_date(item.due_date) %></:col>
            <:col :let={{_id, item}} label="Weight"><%= item.grade_weight * 100 %>%</:col>
            <:action :let={{_id, item}}>
              <%= if is_nil(@course.finalized_at) do %>
                <.link navigate={
                  ~p"/courses/#{@course}/assignments/#{@assignment}/checklist_items/#{item}/edit"
                }>
                  Edit
                </.link>
              <% end %>
            </:action>
            <:action :let={{id, item}}>
              <%= if is_nil(@course.finalized_at) do %>
                <.link
                  phx-click={JS.push("delete", value: %{id: item.id}) |> hide("##{id}")}
                  data-confirm="Are you sure?"
                >
                  Delete
                </.link>
              <% end %>
            </:action>
          </.table>
        <% end %>
      </div>
      <.footer>
        <:left>
          <.link navigate={~p"/courses/#{@course}"}>
            <.button>Back to Course</.button>
          </.link>
        </:left>
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
    checklist_items = Courses.load_checklist_items(assignment)

    {:noreply,
     socket
     |> assign(:page_title, assignment.title)
     |> assign(:assignment, assignment)
     |> assign(:course, course)
     |> stream(:checklist_items, checklist_items)}
  end
end

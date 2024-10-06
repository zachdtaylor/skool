defmodule SkoolWeb.CourseLive.Show do
  use SkoolWeb, :live_view

  alias Skool.Courses

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col relative">
      <.header>
        <%= @course.name %>
        <:subtitle>
          <%= format_date(@course.start_date) %> - <%= format_date(@course.end_date) %>
        </:subtitle>
        <:actions>
          <%= cond do %>
            <% is_nil(@course.finalized_at) -> %>
              <.button phx-click="finalize">Finalize</.button>
              <.dropdown id="course-menu">
                <:options>
                  <.link navigate={~p"/courses/#{@course}/edit"}>
                    <.dropdown_option icon="hero-pencil-square" text="Edit course" />
                  </.link>
                  <.link navigate={~p"/courses/#{@course}/collaborators"}>
                    <.dropdown_option icon="hero-clipboard" text="Manage collaborators" />
                  </.link>
                  <form phx-submit="split_weights">
                    <button phx-click={JS.toggle(to: "#course-menu-content")}>
                      <.dropdown_option icon="hero-arrows-right-left" text="Split assignment weights" />
                    </button>
                  </form>
                </:options>
              </.dropdown>
            <% not @enrolled? -> %>
              <.button phx-click="enroll">Enroll</.button>
            <% true -> %>
              <div class="flex flex-col justify-center">
                <.badge type="success">Enrolled</.badge>
              </div>
          <% end %>
        </:actions>
      </.header>
      <div class="p-4">
        <p :for={paragraph <- String.split(@course.description || "", "\n")} class="pb-2">
          <%= paragraph %>
        </p>
        <div class="grid grid-cols-2 items-center my-8">
          <h1 class="text-md font-bold">Assignments</h1>
          <%= if is_nil(@course.finalized_at) do %>
            <.link navigate={~p"/courses/#{@course}/assignments/new"} class="justify-self-end">
              <.button>New Assignment</.button>
            </.link>
          <% end %>
        </div>
        <.table
          id="assignments"
          rows={@streams.assignments}
          row_click={
            fn {_id, assignment} -> JS.navigate(~p"/courses/#{@course}/assignments/#{assignment}") end
          }
        >
          <:col :let={{_id, assignment}} label="Title"><%= assignment.title %></:col>
          <:col :let={{_id, assignment}} label="Kind">
            <%= capitalize(assignment.kind) %>
          </:col>
          <:col :let={{_id, assignment}} label="Due Date">
            <%= format_date(assignment.due_date) %>
          </:col>
          <:col :let={{_id, assignment}} label="Start Date">
            <%= format_date(assignment.start_date) %>
          </:col>
          <:col :let={{_id, assignment}} label="End Date">
            <%= format_date(assignment.end_date) %>
          </:col>
          <:col :let={{_id, assignment}} label="Repeats">
            <%= display_repeats(assignment) %>
          </:col>
          <:col :let={{_id, assignment}} label="Weight">
            <%= format_percent(assignment.grade_weight) %>
          </:col>
          <:action :let={{_id, assignment}}>
            <%= if is_nil(@course.finalized_at) do %>
              <.link navigate={~p"/courses/#{@course}/assignments/#{assignment}/edit"}>
                Edit
              </.link>
            <% end %>
          </:action>
          <:action :let={{id, assignment}}>
            <%= if is_nil(@course.finalized_at) do %>
              <.link
                phx-click={JS.push("delete", value: %{id: assignment.id}) |> hide("##{id}")}
                data-confirm="Are you sure?"
              >
                Delete
              </.link>
            <% end %>
          </:action>
        </.table>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    course = id |> Courses.get_course!() |> Courses.preload_assignments()

    {:noreply,
     socket
     |> assign(:page_title, course.name)
     |> assign(:course, course)
     |> assign(:enrolled?, Courses.is_enrolled?(course, socket.assigns.current_user))
     |> stream(:assignments, course.assignments)
     |> assign(:active_tab, :courses)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    assignment = Courses.get_assignment!(id)
    {:ok, _} = Courses.delete_assignment(assignment)

    {:noreply, stream_delete(socket, :assignments, assignment)}
  end

  def handle_event("finalize", _params, socket) do
    socket.assigns.course
    |> Courses.update_course(%{finalized_at: DateTime.utc_now()})
    |> case do
      {:ok, course} ->
        {:noreply, assign(socket, course: course)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to finalize course")}
    end
  end

  def handle_event("enroll", _params, socket) do
    course_id = socket.assigns.course.id
    user_id = socket.assigns.current_user.id

    case Courses.enroll_user(course_id, user_id) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "You have been enrolled in this course!")
         |> assign(:enrolled?, true)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to enroll in this course")}
    end
  end

  def handle_event("split_weights", _params, socket) do
    course = Courses.split_weights!(socket.assigns.course)
    {:noreply, stream(socket, :assignments, course.assignments)}
  end
end

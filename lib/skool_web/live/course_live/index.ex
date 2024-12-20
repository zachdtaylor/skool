defmodule SkoolWeb.CourseLive.Index do
  use SkoolWeb, :live_view

  alias Skool.Courses

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col relative">
      <.header>
        Courses
        <:actions>
          <.link navigate={~p"/courses/new"}>
            <.button>New Course</.button>
          </.link>
        </:actions>
      </.header>
      <div class="p-4">
        <h1 class="font-bold">Current</h1>
        <.course_table courses={@streams.current_courses} />
        <h1 class="font-bold mt-8">Upcoming</h1>
        <.course_table courses={@streams.upcoming_courses} />
        <h1 class="font-bold mt-8">Past</h1>
        <.course_table courses={@streams.past_courses} />
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :current_courses,
       Courses.list_courses(socket.assigns.current_user, timeframe: :current)
     )
     |> stream(
       :upcoming_courses,
       Courses.list_courses(socket.assigns.current_user, timeframe: :upcoming)
     )
     |> stream(:past_courses, Courses.list_courses(socket.assigns.current_user, timeframe: :past))
     |> assign(:active_tab, :courses)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    course = Courses.get_course!(id)
    {:ok, _} = Courses.delete_course(course)

    {:noreply, stream_delete(socket, :courses, course)}
  end

  defp course_table(assigns) do
    ~H"""
    <.table
      id="current_courses"
      rows={@courses}
      row_click={fn {_id, course} -> JS.navigate(~p"/courses/#{course.id}") end}
    >
      <:col :let={{_id, course}} label="Name">
        <div class="grid grid-cols-[1rem_1fr] gap-3 items-center">
          <div class="rounded-full w-4 h-4" style={"background: #{course.color}"} /><%= course.name %>
        </div>
      </:col>
      <:col :let={{_id, course}} label="Start Date"><%= format_date(course.start_date) %></:col>
      <:col :let={{_id, course}} label="End Date"><%= format_date(course.end_date) %></:col>
      <:col :let={{_id, course}} label="Status">
        <div class="w-fit">
          <%= case course.status do %>
            <% "enrolled" -> %>
              <.badge type="success">Enrolled</.badge>
            <% "finalized" -> %>
              <.badge type="caution">Finalized</.badge>
            <% _ -> %>
              <.badge type="info">In Progress</.badge>
          <% end %>
        </div>
      </:col>
      <:action :let={{_id, course}}>
        <div class="sr-only">
          <.link navigate={~p"/courses/#{course.id}"}>Show</.link>
        </div>
        <%= if is_nil(course.finalized_at) do %>
          <.link navigate={~p"/courses/#{course.id}/edit"}>Edit</.link>
        <% end %>
      </:action>
    </.table>
    """
  end
end

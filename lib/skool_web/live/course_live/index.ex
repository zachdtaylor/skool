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
        <.table
          id="courses"
          rows={@streams.courses}
          row_click={fn {_id, course} -> JS.navigate(~p"/courses/#{course.id}") end}
        >
          <:col :let={{_id, course}} label="Name"><%= course.name %></:col>
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
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :courses, Courses.list_courses(socket.assigns.current_user))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    course = Courses.get_course!(id)
    {:ok, _} = Courses.delete_course(course)

    {:noreply, stream_delete(socket, :courses, course)}
  end
end

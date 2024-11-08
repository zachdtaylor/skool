defmodule SkoolWeb.TasksLive.Index do
  use SkoolWeb, :live_view

  alias Skool.{DateHelpers, Tasks}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col relative">
      <.header>
        Tasks
      </.header>
      <div class="p-4">
        <h1>Due Today (<%= format_date(@todays_date) %>)</h1>
        <.table id="todays_tasks" rows={@streams.todays_tasks}>
          <:col :let={{_id, task}} label="Name"><.task_name task={task} /></:col>
          <:col :let={{_id, task}} label="Course"><%= task.assignment.course.name %></:col>
          <:action :let={{_id, task}}>
            <%= if is_nil(task.completed_at) do %>
              <button phx-click="complete" phx-value-task_id={task.id}>Complete Task</button>
            <% else %>
              <.icon name="hero-check-circle" class="text-secondary" />
            <% end %>
          </:action>
        </.table>
      </div>

      <div class="p-4">
        <h1>Due this week</h1>
        <.table id="week_tasks" rows={@streams.week_tasks}>
          <:col :let={{_id, task}} label="Name"><.task_name task={task} /></:col>
          <:col :let={{_id, task}} label="Due Date"><%= format_date(task.due_date) %></:col>
          <:col :let={{_id, task}} label="Course"><%= task.assignment.course.name %></:col>
          <:action :let={{_id, task}}>
            <%= if is_nil(task.completed_at) do %>
              <button phx-click="complete" phx-value-task_id={task.id}>Complete Task</button>
            <% else %>
              <.icon name="hero-check-circle" class="text-secondary" />
            <% end %>
          </:action>
        </.table>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_todays_date()
     |> stream_tasks()
     |> stream_week_tasks()
     |> assign(:active_tab, :tasks)
     |> assign(:page_title, "Tasks")}
  end

  @impl true
  def handle_event("complete", %{"task_id" => id}, socket) do
    {:ok, _} = Tasks.complete_task(id)

    {:noreply, socket |> stream_tasks() |> stream_week_tasks()}
  end

  defp assign_todays_date(socket) do
    date = DateHelpers.today(socket.assigns.current_user)
    assign(socket, todays_date: date)
  end

  defp stream_tasks(socket) do
    stream(
      socket,
      :todays_tasks,
      Tasks.list_tasks_for_date(socket.assigns.current_user, socket.assigns.todays_date)
    )
  end

  defp stream_week_tasks(socket) do
    stream(
      socket,
      :week_tasks,
      Tasks.list_tasks_for_week(socket.assigns.current_user, socket.assigns.todays_date)
    )
  end

  defp task_name(%{task: %Tasks.Task{checklist_item: checklist_item}} = assigns)
       when not is_nil(checklist_item) do
    ~H"""
    <p>
      <%= @task.checklist_item.title %>
      <span class="text-xs text-gray-500">(<%= @task.assignment.title %>)</span>
    </p>
    """
  end

  defp task_name(%{task: %Tasks.Task{}} = assigns) do
    ~H"""
    <p><%= @task.assignment.title %></p>
    """
  end
end

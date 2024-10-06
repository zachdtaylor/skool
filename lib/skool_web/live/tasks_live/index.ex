defmodule SkoolWeb.TasksLive.Index do
  use SkoolWeb, :live_view

  alias Skool.{DateHelpers, Tasks}

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

defmodule SkoolWeb.TasksLive.Index do
  use SkoolWeb, :live_view

  alias Skool.Tasks

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream_tasks(socket)}
  end

  @impl true
  def handle_event("complete", %{"task_id" => id}, socket) do
    {:ok, _} = Tasks.complete_task(id)

    {:noreply, stream_tasks(socket)}
  end

  defp stream_tasks(socket) do
    stream(socket, :todays_tasks, Tasks.list_todays_tasks(socket.assigns.current_user))
  end
end

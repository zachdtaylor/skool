defmodule SkoolWeb.CourseLive.InviteCollaborators do
  use SkoolWeb, :live_view

  alias Skool.Accounts
  alias Skool.Courses
  alias Skool.Repo

  def mount(%{"id" => id}, _session, socket) do
    course = Courses.get_course!(id)

    {:ok,
     socket
     |> assign_course_name(course)
     |> assign_search_results(nil)
     |> assign_collaborators(course)}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    {:noreply, assign(socket, course_id: id)}
  end

  def handle_event("search", %{"value" => value}, socket) do
    {:noreply, socket |> assign_search_results(value)}
  end

  def handle_event("invite", %{"user_id" => user_id}, socket) do
    case Courses.invite_collaborator(socket.assigns.course_id, user_id) do
      {:ok, _} ->
        course = Courses.get_course!(socket.assigns.course_id)
        {:noreply, socket |> assign_collaborators(course) |> assign_search_results(nil)}

      {:error, :already_invited} ->
        {:noreply, socket |> put_flash(:error, "User could not be invited.")}
    end
  end

  def handle_event("disinvite", %{"user_id" => user_id}, socket) do
    Courses.disinvite_collaborator(socket.assigns.course_id, user_id)
    course = Courses.get_course!(socket.assigns.course_id)
    {:noreply, socket |> assign_collaborators(course) |> assign_search_results(nil)}
  end

  defp assign_course_name(socket, course) do
    assign(socket, course_name: course.name)
  end

  defp assign_search_results(socket, query) when is_nil(query) or query == "" do
    assign(socket, search_results: [])
  end

  defp assign_search_results(socket, query) do
    results = Accounts.search_users(query, socket.assigns.current_user)
    assign(socket, search_results: results)
  end

  defp assign_collaborators(socket, course) do
    course = Repo.preload(course, :collaborators)
    assign(socket, collaborators: course.collaborators)
  end
end

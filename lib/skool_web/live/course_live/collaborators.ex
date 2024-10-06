defmodule SkoolWeb.CourseLive.Collaborators do
  use SkoolWeb, :live_view

  alias Skool.Accounts
  alias Skool.Courses
  alias Skool.Repo

  def mount(%{"id" => id}, _session, socket) do
    course = Courses.get_course!(id)

    {:ok,
     socket
     |> assign_course_name(course)
     |> assign_created_by_name(course)
     |> assign_search_results(nil)
     |> assign_collaborators(course)
     |> assign(:active_tab, :courses)}
  end

  def handle_params(%{"id" => id}, url, socket) do
    path = URI.parse(url).path
    {:noreply, assign(socket, course_id: id, current_path: path)}
  end

  def handle_event("search", %{"value" => value}, socket) do
    {:noreply, socket |> assign_search_results(value)}
  end

  def handle_event("invite", %{"user_id" => user_id}, socket) do
    case Courses.invite_collaborator(socket.assigns.course_id, user_id) do
      {:ok, _} ->
        course = Courses.get_course!(socket.assigns.course_id)
        {:noreply, socket |> assign_collaborators(course) |> assign_search_results(nil)}

      {:error, _} ->
        {:noreply, socket |> put_flash(:error, "User could not be invited.")}
    end
  end

  def handle_event("disinvite", %{"user_id" => user_id}, socket) do
    case Courses.disinvite_collaborator(socket.assigns.course_id, user_id) do
      {0, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not disinvite user")
         |> push_navigate(to: socket.assigns.current_path)}

      {n, _} when n > 0 ->
        course = Courses.get_course!(socket.assigns.course_id)
        {:noreply, socket |> assign_collaborators(course) |> assign_search_results(nil)}
    end
  end

  defp assign_course_name(socket, course) do
    assign(socket, course_name: course.name)
  end

  defp assign_created_by_name(socket, course) do
    created_by = Courses.get_course_creator(course)
    assign(socket, created_by_name: created_by.full_name)
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

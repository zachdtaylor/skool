defmodule SkoolWeb.CourseLive.Collaborators do
  use SkoolWeb, :live_view

  alias Skool.Accounts
  alias Skool.Courses
  alias Skool.Repo

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col relative">
      <.header>
        Create a New Course
        <:subtitle><%= @course_name %></:subtitle>
      </.header>
      <div class="p-4 flex flex-col gap-8 flex-1">
        <p class="text-sm">
          If this is a goal you're working on with someone else, you can invite them to help you create the course.
        </p>
        <div>
          <p class="text-sm font-bold pb-2">Invite Collaborators</p>
          <div class="relative w-80">
            <input
              type="text"
              placeholder="Enter their email or name"
              class="border border-slate-100 p-2 rounded w-full"
              phx-keyup="search"
            />
            <%= if length(@search_results) > 0 do %>
              <div class="absolute bg-white z-10 w-full p-2 flex flex-col gap-2">
                <%= for user <- @search_results do %>
                  <button
                    class="p-2 rounded-sm w-full text-left hover:bg-brand hover:text-white"
                    phx-click="invite"
                    phx-value-user_id={user.id}
                  >
                    <p class="text-sm font-bold"><%= user.full_name %></p>
                    <p class="text-xs"><%= user.email %></p>
                  </button>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
        <div>
          <p class="text-sm font-bold pb-2">Collaborators Added</p>
          <div class="rounded-md border-slate-100 border w-80">
            <div class="text-sm bg-white p-2 flex gap-2">
              <%= @created_by_name %>
              <span class="bg-compliment text-slate-900 rounded-full px-2 py-[0.15rem] text-xs">
                creator
              </span>
            </div>
            <%= for user <- @collaborators do %>
              <div
                id={"collaborator-#{user.id}"}
                class="text-sm bg-white p-2 grid grid-cols-[1fr_min-content] items-center"
              >
                <div class="flex gap-2">
                  <%= user.full_name %>
                  <span class="bg-secondary text-white rounded-full px-2 py-[0.15rem] text-xs">
                    collaborator
                  </span>
                </div>
                <button
                  id={"remove-collaborator-#{user.id}"}
                  phx-hook="OptimisticRemove"
                  data-remove-id={"collaborator-#{user.id}"}
                  data-event="disinvite"
                  data-user_id={user.id}
                >
                  <.icon name="hero-x-mark" />
                </button>
              </div>
            <% end %>
          </div>
        </div>
      </div>
      <.footer>
        <:right>
          <%= if @live_action == :invite do %>
            <.link navigate={~p"/courses/#{@course_id}/edit"}>
              <.button>Continue</.button>
            </.link>
          <% else %>
            <.link navigate={~p"/courses/#{@course_id}"}>
              <.button>Save</.button>
            </.link>
          <% end %>
        </:right>
      </.footer>
    </div>
    """
  end

  @impl true
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

  @impl true
  def handle_params(%{"id" => id}, url, socket) do
    path = URI.parse(url).path
    {:noreply, assign(socket, course_id: id, current_path: path)}
  end

  @impl true
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

defmodule SkoolWeb.TasksLive.Index do
  alias Skool.{DateHelpers, Tasks}

  use SkoolWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col relative">
      <.header>
        Tasks
      </.header>
      <div class="p-4">
        <div id="calendar-root">
          <div id="calendar-header" class="pb-4 flex gap-4">
            <div>
              <button class="mr-2" phx-click="prev_month">&larr;</button>
              <button phx-click="next_month">&rarr;</button>
            </div>
            <h1 class="font-bold"><%= month_name(@current_month) %> <%= @current_year %></h1>
          </div>
          <div id="calendar-day-labels" class="flex">
            <%= for day <- ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] do %>
              <p class="flex-1 text-center"><%= day %></p>
            <% end %>
          </div>
          <div class="grid grid-cols-7">
            <%= for row <- 0..(number_of_rows(@days_in_month, @first_of_month_day_of_week) - 1) do %>
              <%= for column <- 0..6 do %>
                <.calendar_day
                  current_year={@current_year}
                  current_month={@current_month}
                  day_of_month={DateHelpers.day_of_month(row, column, @first_of_month_day_of_week)}
                  days_in_month={@days_in_month}
                  tasks={@tasks}
                  todays_date={@todays_date}
                />
              <% end %>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_todays_date()
     |> assign(:active_tab, :tasks)
     |> assign(:page_title, "Tasks")}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    [year, month] = current_month_year(socket, params)

    first_of_month = Date.new!(year, month, 1)

    {:noreply,
     socket
     |> assign(:params, params)
     |> assign(:current_month, month)
     |> assign(:current_year, year)
     |> assign(
       :first_of_month_day_of_week,
       Date.day_of_week(first_of_month, :sunday)
     )
     |> assign(:days_in_month, Date.days_in_month(first_of_month))
     |> assign_tasks()}
  end

  @impl true
  def handle_event("toggle_complete", %{"task_id" => id}, socket) do
    {:ok, _} = Tasks.toggle_completed_at(id)

    {:noreply, assign_tasks(socket)}
  end

  def handle_event("next_month", _payload, socket) do
    {:noreply, socket |> push_patch(to: ~p"/tasks?month=#{next_month(socket)}")}
  end

  def handle_event("prev_month", _payload, socket) do
    {:noreply, socket |> push_patch(to: ~p"/tasks?month=#{prev_month(socket)}")}
  end

  defp assign_todays_date(socket) do
    date = DateHelpers.today(socket.assigns.current_user)
    assign(socket, todays_date: date)
  end

  defp assign_tasks(socket) do
    tasks =
      socket.assigns.current_year
      |> Tasks.tasks_for_month(socket.assigns.current_month)
      |> Enum.group_by(& &1.due_date.day)

    assign(socket, tasks: tasks)
  end

  defp next_month(socket) do
    [year, month] = current_month_year(socket)

    case month do
      12 -> "#{year + 1}-1"
      _ -> "#{year}-#{month + 1}"
    end
  end

  defp prev_month(socket) do
    [year, month] = current_month_year(socket)

    case month do
      1 -> "#{year - 1}-12"
      _ -> "#{year}-#{month - 1}"
    end
  end

  defp current_month_year(socket, params \\ nil) do
    today = DateHelpers.today(socket.assigns.current_user)

    params = params || Map.get(socket.assigns, :params)

    params
    |> Map.get("month", "#{today.year}-#{today.month}")
    |> String.split("-")
    |> Enum.map(&String.to_integer/1)
  end

  defp calendar_day(assigns) do
    ~H"""
    <div class="border border-gray-100 border-solid h-48 flex-1">
      <div class="p-2 pt-1">
        <%= if @day_of_month in 1..@days_in_month do %>
          <div class="flex justify-center">
            <p class={[
              "text-sm text-gray-500 font-bold rounded-full h-8 w-8 p-1 flex flex-col justify-center text-center",
              Date.compare(@todays_date, Date.new!(@current_year, @current_month, @day_of_month)) ==
                :eq && "bg-gray-200"
            ]}>
              <%= @day_of_month %>
            </p>
          </div>
          <div>
            <%= for task <- Map.get(@tasks, @day_of_month, []) do %>
              <button
                phx-click="toggle_complete"
                phx-value-task_id={task.id}
                class="w-4 h-4 rounded-full group relative inline-block md:mx-[2px]"
                style={"background: #{if is_nil(task.completed_at), do: task.color, else: "#ccc"}"}
              >
                <div class="hidden group-hover:block bg-gray-200 rounded-md w-fit py-1 px-2 bottom-6 left-[50%] translate-x-[-50%] absolute whitespace-nowrap">
                  <%= task.title %>
                </div>
              </button>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp number_of_rows(days_in_month, first_of_month_day_of_week) do
    days_in_first_week = 8 - first_of_month_day_of_week
    remaining_days = days_in_month - days_in_first_week
    full_weeks_after_first_week = div(remaining_days, 7)
    additional_partial_weeks = if rem(remaining_days, 7) > 0, do: 1, else: 0
    1 + full_weeks_after_first_week + additional_partial_weeks
  end
end

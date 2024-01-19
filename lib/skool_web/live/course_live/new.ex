defmodule SkoolWeb.CourseLive.New do
  use SkoolWeb, :live_view

  alias Skool.Courses
  alias Skool.Courses.Course

  def mount(_params, _session, socket) do
    changeset = Courses.change_course(%Course{})
    {:ok, socket |> assign_form(changeset)}
  end

  def handle_event("create", %{"course" => course}, socket) do
    case Courses.create_course(course) do
      {:ok, course} ->
        {:noreply, push_navigate(socket, to: ~p"/courses/#{course.id}/collaborators/invite")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "course")

    assign(socket, form: form)
  end
end

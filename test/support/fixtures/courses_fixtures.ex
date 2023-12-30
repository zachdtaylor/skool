defmodule Skool.CoursesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Skool.Courses` context.
  """

  @doc """
  Generate a course.
  """
  def course_fixture(attrs \\ %{}) do
    {:ok, course} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Skool.Courses.create_course()

    course
  end
end

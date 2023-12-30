defmodule SkoolWeb.CourseLiveTest do
  use SkoolWeb.ConnCase

  import Phoenix.LiveViewTest
  import Skool.CoursesFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_course(_) do
    course = course_fixture()
    %{course: course}
  end

  describe "Index" do
    setup [:create_course]

    test "lists all courses", %{conn: conn, course: course} do
      {:ok, _index_live, html} = live(conn, ~p"/courses")

      assert html =~ "Listing Courses"
      assert html =~ course.name
    end

    test "saves new course", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/courses")

      assert index_live |> element("a", "New Course") |> render_click() =~
               "New Course"

      assert_patch(index_live, ~p"/courses/new")

      assert index_live
             |> form("#course-form", course: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#course-form", course: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/courses")

      html = render(index_live)
      assert html =~ "Course created successfully"
      assert html =~ "some name"
    end

    test "updates course in listing", %{conn: conn, course: course} do
      {:ok, index_live, _html} = live(conn, ~p"/courses")

      assert index_live |> element("#courses-#{course.id} a", "Edit") |> render_click() =~
               "Edit Course"

      assert_patch(index_live, ~p"/courses/#{course}/edit")

      assert index_live
             |> form("#course-form", course: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#course-form", course: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/courses")

      html = render(index_live)
      assert html =~ "Course updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes course in listing", %{conn: conn, course: course} do
      {:ok, index_live, _html} = live(conn, ~p"/courses")

      assert index_live |> element("#courses-#{course.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#courses-#{course.id}")
    end
  end

  describe "Show" do
    setup [:create_course]

    test "displays course", %{conn: conn, course: course} do
      {:ok, _show_live, html} = live(conn, ~p"/courses/#{course}")

      assert html =~ "Show Course"
      assert html =~ course.name
    end

    test "updates course within modal", %{conn: conn, course: course} do
      {:ok, show_live, _html} = live(conn, ~p"/courses/#{course}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Course"

      assert_patch(show_live, ~p"/courses/#{course}/show/edit")

      assert show_live
             |> form("#course-form", course: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#course-form", course: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/courses/#{course}")

      html = render(show_live)
      assert html =~ "Course updated successfully"
      assert html =~ "some updated name"
    end
  end
end

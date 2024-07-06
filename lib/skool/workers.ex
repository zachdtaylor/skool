defmodule Skool.Workers do
  def new_create_tasks(course_id, user_id) do
    Skool.Workers.Tasks.new(%{
      "type" => "create_tasks",
      "course_id" => course_id,
      "user_id" => user_id
    })
  end
end

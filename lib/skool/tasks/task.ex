defmodule Skool.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :completed_at, :utc_datetime
    field :description, :string
    field :completed_by_id, :id
    field :course_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:description, :completed_at])
    |> validate_required([:description, :completed_at])
  end
end

defmodule Skool.Courses.Course do
  use Ecto.Schema
  import Ecto.Changeset

  schema "courses" do
    field :name, :string
    field :created_by_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :created_by_id])
    |> validate_required([:name, :created_by_id])
  end
end

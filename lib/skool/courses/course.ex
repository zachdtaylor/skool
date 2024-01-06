defmodule Skool.Courses.Course do
  use Ecto.Schema
  import Ecto.Changeset

  schema "courses" do
    field :name, :string
    field :description
    field :category, :string
    field :created_by_id, :id
    field :start_date, :date
    field :end_date, :date
    field :deleted_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :description, :category, :start_date, :end_date, :created_by_id])
    |> validate_required([:name, :start_date, :end_date, :created_by_id])
  end
end

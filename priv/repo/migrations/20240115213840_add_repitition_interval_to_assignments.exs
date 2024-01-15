defmodule Skool.Repo.Migrations.AddRepititionIntervalToAssignments do
  use Ecto.Migration

  def change do
    alter table(:assignments) do
      add :recurrance_interval, :float
      add :recurrance_unit, :string
    end
  end
end

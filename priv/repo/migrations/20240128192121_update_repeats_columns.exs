defmodule Skool.Repo.Migrations.UpdateRepeatsColumns do
  use Ecto.Migration

  def change do
    alter table(:assignments) do
      remove :recurrance_interval
      remove :recurrance_unit

      add :repeats_every, :integer
      # :day, :week, :month, :year
      add :repeats_every_unit, :string
      # for months: "[day]", "[nth_day_of_week]", "[last_day_of_week]", "[first_day_of_week]"
      # for weeks: "[monday]", "[monday, wednesday]", "[sunday, monday, tuesday, wednesday, thursday, friday, saturday]"
      add :repeats_on, {:array, :string}
    end
  end
end

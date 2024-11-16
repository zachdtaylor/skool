defmodule Skool.Repo.Migrations.AddColorToCourses do
  use Ecto.Migration

  def change do
    alter table(:courses) do
      add :color, :string, default: "#7752fe"
    end
  end
end

defmodule Skool.Repo.Migrations.AddDescriptionToCourses do
  use Ecto.Migration

  def change do
    alter table(:courses) do
      add :description, :string
    end
  end
end

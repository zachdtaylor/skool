defmodule Skool.Repo.Migrations.AddNameToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :full_name, :string, generated: "ALWAYS AS (first_name || ' ' || last_name) STORED"
    end
  end
end

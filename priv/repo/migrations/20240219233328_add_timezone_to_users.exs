defmodule Skool.Repo.Migrations.AddTimezoneToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :preferred_timezone, :string, default: "America/Denver"
    end
  end
end

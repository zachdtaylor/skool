defmodule Skool.Repo.Migrations.UpdateRepeatsOnType do
  use Ecto.Migration

  def change do
    alter table(:assignments) do
      modify :repeats_on, :string
    end
  end
end

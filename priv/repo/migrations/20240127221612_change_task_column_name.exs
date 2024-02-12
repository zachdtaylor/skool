defmodule Skool.Repo.Migrations.ChangeTaskColumnName do
  use Ecto.Migration

  def change do
    rename table("assignment_checklist_items"), to: table("checklist_items")
    rename table(:tasks), :assignment_checklist_item_id, to: :checklist_item_id
  end
end

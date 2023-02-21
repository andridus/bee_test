defmodule BeeTest.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :comment, :text
      add :status, :string, default: "PENDING", null: false
      add :is_approved, :boolean, default: false
      add :approved_at, :utc_datetime
      add :is_deleted, :boolean, default: false
      add :deleted_at, :utc_datetime
      add :user_id, references(:users)
      add :post_id, references(:posts)

      timestamps()
    end
  end
end

defmodule BeeTest.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :slug, :string
      add :content, :text
      add :status, :string, default: "DRAFT", null: false
      add :is_deleted, :boolean, default: false, null: false
      add :deleted_at, :utc_datetime
      add :is_published, :boolean, default: false, null: false
      add :published_at, :utc_datetime
      add :user_id, references(:users)

      timestamps()
    end
  end
end

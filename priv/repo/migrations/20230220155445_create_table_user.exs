defmodule BeeTest.Repo.Migrations.CreateTableUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :username, :string
      add :password, :string
      add :function, :string
      add :permissions, {:array, :string}

      timestamps()
    end
  end
end

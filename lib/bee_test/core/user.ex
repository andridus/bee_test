defmodule BeeTest.Core.User do
  use Ecto.Schema
  use Bee.Schema

  generate_bee do
    schema "users" do
      field :name, :string
      field :username, :string
      field :password, :string
      field :function, Ecto.Enum, values: [:user, :manager, :admin], default: :user
      field :permissions, {:array, Ecto.Enum}, values: [:basic, :module1, :module2, :full_access], default: []

      timestamps()
    end
  end

  defmodule Api do
    @schema BeeTest.Core.User
    use Bee.Api, repo: BeeTest.Repo
  end
end

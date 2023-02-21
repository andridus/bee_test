defmodule BeeTest.Core.User do
  @moduledoc false
  use Ecto.Schema
  use Bee.Schema

  alias BeeTest.Core.Post

  generate_bee do
    permission(:basic, [:name, :username, :password])
    permission(:admin, [:id, :inserted_at, :updated_at], extends: :basic)

    schema "users" do
      field :name, :string
      field :username, :string
      field :password, :string
      field :function, Ecto.Enum, values: [:user, :manager, :admin], default: :user

      field :permissions, {:array, Ecto.Enum},
        values: [:basic, :module1, :module2, :module3, :module4, :full_access],
        default: []

      timestamps()

      has_many :posts, Post
    end
  end

  defmodule Api do
    @moduledoc false
    @schema BeeTest.Core.User
    use Bee.Api, repo: BeeTest.Repo
  end
end

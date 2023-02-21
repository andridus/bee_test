defmodule BeeTest.Core.Post do
  @moduledoc false
  use Ecto.Schema
  use Bee.Schema

  alias BeeTest.Core.{User, Comment}

  generate_bee do
    permission(:basic, [:name, :username, :password])
    permission(:admin, [:id, :inserted_at, :updated_at], extends: :basic)

    schema "posts" do
      field :title, :string
      field :slug, :string
      field :content, :string
      field :status, Ecto.Enum, values: [:DRAFT, :PUBLISHED, :DELETED], default: :DRAFT
      field :is_deleted, :boolean, default: false
      field :deleted_at, :utc_datetime
      field :is_published, :boolean, default: false
      field :published_at, :utc_datetime

      timestamps()

      belongs_to :user, User
      has_many :comments, Comment
    end
  end

  defmodule Api do
    @moduledoc false
    @schema BeeTest.Core.Post
    use Bee.Api, repo: BeeTest.Repo
  end
end

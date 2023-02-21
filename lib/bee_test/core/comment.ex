defmodule BeeTest.Core.Comment do
  alias BeeTest.Core.{User, Post}

  use Ecto.Schema
  use Bee.Schema

  generate_bee do
    permission(:basic, [:comment, :status, :user_id])
    permission(:admin, [:id, :inserted_at, :updated_at], extends: :basic)

    schema "comments" do
      field :comment, :string
      field :status, Ecto.Enum, values: [:PENDING, :APPROVED, :DELETED], default: :PENDING
      field :is_deleted, :boolean, default: false
      field :deleted_at, :utc_datetime
      field :is_approved, :boolean, default: false
      field :approved_at, :utc_datetime
      timestamps()

      belongs_to :user, User
      belongs_to :post, Post
    end
  end

  defmodule Api do
    @moduledoc false
    @schema BeeTest.Core.Comment
    use Bee.Api, repo: BeeTest.Repo
  end
end

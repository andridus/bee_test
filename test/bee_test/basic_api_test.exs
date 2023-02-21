defmodule BeeTest.BasicApiTest do
  use BeeTestWeb.ConnCase

  alias BeeTest.Core.{Comment, Post, User}

  describe "Basic Api" do
    test "one" do
      assert {:ok, %User{id: id, function: :user}} =
               User.Api.insert(%{
                 id: 1,
                 name: "Fulan",
                 username: "fulan",
                 function: :user,
                 permissions: [:module1, :module2]
               })

      assert is_integer(id)
      assert {:ok, %User{id: ^id}} = User.Api.get_by(where: [name: "Fulan"])
      assert {:ok, %User{id: ^id, function: :user}} = User.Api.get_by(where: [username: "fulan"])
    end
    test "all" do
      ## create many post and comments
       functions = [:user, :manager, :admin]
       modules = [:basic, :module1, :module2, :module3, :module4, :full_access]
       posts_statuses = [:DRAFT, :PUBLISHED, :DELETED]
       comment_statuses = [:PENDING, :APPROVED, :DELETED]
       users_id = for _q <- 0..100 do
         assert {:ok, %{id: id}} = User.Api.insert(%{
            name: "Fulan - #{Bee.unique(35)}",
            username: "fulan_#{Bee.unique(35)}",
            function: Enum.random(functions),
            permissions: Enum.take_random(modules, :rand.uniform(4))
          })
          id
       end
       ### Create posts
       posts_id = for _q <- 0..100 do
         status = Enum.random(posts_statuses)
         assert {:ok, %{id: id}} = Post.Api.insert(%{
            title: create_text(3),
            slug: create_text(3, "_"),
            user_id: Enum.random(users_id),
            status: status,
            is_published: status == :PUBLISHED,
            published_at: if( status == :PUBLISHED, do: DateTime.utc_now())
          })
          id
       end

       ### Create comments
       _comments_id = for _q <- 0..100 do
         status = Enum.random(comment_statuses)
         assert {:ok, %{id: id}} = Comment.Api.insert(%{
            comment: create_text(25),
            slug: create_text(3, "_"),
            user_id: Enum.random(users_id),
            post_id: Enum.random(posts_id),
            status: status,
            is_approved: status == :APPROVED,
            approved_at: if( status == :APPROVED, do: DateTime.utc_now())
          })
          id
       end
      assert [user_id|_] = users_id
      assert 101 = User.Api.count()
      assert {:ok, %{id: ^user_id, posts: [%{comments: [_|_]}|_]}} = User.Api.get(user_id, preload: [posts: [preload: [:comments]]])

      assert [%{id: _}|_] = User.Api.all(where: [function: {:in, [:user]}])
      assert [:name, :username, :password] = User.bee_permission(:basic)

      assert [:name, :username, :password, :id, :inserted_at, :updated_at] =
               User.bee_permission(:admin)

      # assert [
      #          limit: 10,
      #          offset: 10,
      #          where: [],
      #          select: [:username, :name, :password, :inserted_at]
      #        ] =
      #          User.Api.params_to_query(
      #            limit: 10,
      #            fields: "username,name,function,permissions,password,inserted_at",
      #            assocs: "",
      #            filter: "username[eq]='Fulan',function[eq]='admin'",
      #            # [
      #            #  username: "Fulan",
      #            #  function: {:in, "basic"},
      #            #  permissions, {:contains, "basic"},
      #            #  posts: [
      #            #   status: :PUBLISHED
      #            #  ]
      #            # ]
      #            offset: 10,
      #            permission: :admin
      #          )

      # assert {:ok,  :not_found} = User.Api.get_by(where: [{{:in, :permissions}, [:module3]}])
      # assert {:ok,  %User{id: ^id}} = User.Api.get_by(where: [{{:in, :permissions}, [:module1]}])
      ### testing preload
      ### testing save embed schema
    end
    defp create_text(words, sep \\ " "), do: for(_w <- 0..words, do: Bee.unique(:rand.uniform(25))) |> Enum.join(sep)

    # test "Getters" do
    #   assert [] = User.Api.all()
    #   assert {:error, :not_found} = User.Api.get(1)
    #   assert {:error, :not_found} = User.Api.get_by(where: [{{:in, :permissions}, [:basic]}])
    # end
  end
end

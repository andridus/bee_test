defmodule BeeTest.BasicApiTest do
  use BeeTestWeb.ConnCase

  alias BeeTest.Core.{Comment, Post, User}

  describe "Basic Api" do
    test "permissions" do
      assert [:name, :username, :password] = User.bee_permission(:basic)

      assert [:name, :username, :password, :id, :inserted_at, :updated_at] =
               User.bee_permission(:admin)
    end
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
      assert user_id = Enum.random(users_id)
      assert 101 = User.Api.count()
      assert {:ok, %{id: ^user_id, posts: [%{comments: [_|_]}|_]}} =
        User.Api.get(user_id,
        where: [
          posts: [
            __COUNT__: {:id, :gt, 0},
            # __SUM__: {:likes, :gt, 0},
            # __MAX__: {:likes, :gt, 0},
            # __MIN__: {:likes, :gt, 0},
            # __AVG__: {:likes, :gt, 0}
          ]
          # profile: [
          #   email: "fulano@testing.com"
          # ]
        ],
        preload: [
          posts: [preload: [:comments]]
        ])

      ### test filters
      assert [user] = User.Api.all(where: [function: {:in, [:user]}], select: [:username], limit: 1)
      refute user[:id]
      assert [%{username: _}] = User.Api.all(where: [function: {:in, [:user]}], select: [:username], limit: 1)
    end
    test "query relation" do
      assert {:ok, %User{id: uid, function: :user}} =
               User.Api.insert(%{
                 name: "Fulan",
                 username: "fulan",
                 function: :user,
                 permissions: [:module1, :module2]
               })

   assert {:ok, %{id: pid}} = Post.Api.insert(%{
            title: create_text(3),
            slug: create_text(3, "_"),
            user_id: uid,
            status: :PUBLISHED,
            is_published: true,
            published_at: DateTime.utc_now()
          })
    assert {:ok, %{id: _cid}} = Comment.Api.insert(%{
            comment: create_text(25),
            slug: create_text(3, "_"),
            user_id: uid,
            post_id: pid,
            status: :APPROVED,
            is_approved: true,
            approved_at: DateTime.utc_now()
          })
       assert {:ok, %{id: _, posts: [%{id: _, comments: [%{id: _}]}]}} =
        User.Api.get(uid,
        where: [
          posts: [
            status: :PUBLISHED,
            comments: [
              status: {:eq, :APPROVED}
            ]
          ]
        ],
        preload: [posts: [preload: [:comments]]])


      assert {:ok, %{id: _, comments: [], posts: [%{id: _, comments: [%{id: _}]}]}} =
        User.Api.get(uid,
        where: [
          posts: [
            status: :PUBLISHED,
            comments: [
              status: {:eq, :APPROVED}
            ]
          ],
          # comments: [
          #   status: {:eq, :PENDING}
          # ]
        ],
        preload: [posts: [preload: [:comments]], comments: [where: [status: {:eq, :PENDING}]]])

      assert {:ok, %{id: _, comments: [%{id: _}], posts: [%{id: _, comments: [%{id: _}]}]}} =
        User.Api.get(uid,
        where: [
          posts: [
            status: :PUBLISHED,
            comments: [
              status: {:eq, :APPROVED}
            ]
          ],
          comments: [
            status: {:eq, :APPROVED}
          ]
        ],
        preload: [posts: [preload: [:comments]], comments: [where: [status: {:eq, :APPROVED}]]])

      assert {:error, :not_found} =
        User.Api.get(uid,
        where: [
          posts: [
            status: :PUBLISHED,
            comments: [
              status: {:eq, :PENDING}
            ]
          ],
        ], preload: [posts: [preload: [:comments]]])

        assert {:ok, %{id: _}} =
        User.Api.get(uid,
        where: [
          posts: [
            status: :PUBLISHED
          ],
          comments: [
            status: :APPROVED
          ]
        ],
        preload: [
          :comments,
          posts: [preload: [:comments]]
        ])
    end
  end
  defp create_text(words, sep \\ " "), do: for(_w <- 0..words, do: Bee.unique(:rand.uniform(25))) |> Enum.join(sep)
end

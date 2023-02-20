defmodule BeeTest.BasicApiTest do
  use BeeTestWeb.ConnCase

  alias BeeTest.Core.User

  describe "Basic Api" do

    test "setters" do
      assert {:ok, %User{id: id, function: :user}} = User.Api.insert(%{id: 1, name: "Fulan", username: "fulan", function: :user, permissions: [:module1, :module2]})
      assert is_integer(id)
      assert {:ok,  %User{id: ^id}} = User.Api.get_by(where: [name: "Fulan"])
      assert {:ok,  %User{id: ^id, function: :user}} = User.Api.get_by(where: [username: "fulan"])
      assert {:ok,  %{id: _}} = User.Api.get_by(where: [{{:in, :function}, [:user]}])
      # assert {:ok,  :not_found} = User.Api.get_by(where: [{{:in, :permissions}, [:module3]}])
      # assert {:ok,  %User{id: ^id}} = User.Api.get_by(where: [{{:in, :permissions}, [:module1]}])
      ### testing preload
      ### testing save embed schema
    end
    # test "Getters" do
    #   assert [] = User.Api.all()
    #   assert {:error, :not_found} = User.Api.get(1)
    #   assert {:error, :not_found} = User.Api.get_by(where: [{{:in, :permissions}, [:basic]}])
    # end
  end
end

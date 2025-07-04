defmodule Src.UsersTest do
  use Src.DataCase

  alias Src.Users

  describe "users" do
    alias Src.Users.User

    import Src.UsersFixtures

    @invalid_attrs %{username: nil, password: nil, email: nil, birthdate: nil, firstname: nil, lastname: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{username: "some username", password: "some password", email: "some email", birthdate: ~D[2025-06-21], firstname: "some firstname", lastname: "some lastname"}

      assert {:ok, %User{} = user} = Users.create_user(valid_attrs)
      assert user.username == "some username"
      assert user.password == "some password"
      assert user.email == "some email"
      assert user.birthdate == ~D[2025-06-21]
      assert user.firstname == "some firstname"
      assert user.lastname == "some lastname"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{username: "some updated username", password: "some updated password", email: "some updated email", birthdate: ~D[2025-06-22], firstname: "some updated firstname", lastname: "some updated lastname"}

      assert {:ok, %User{} = user} = Users.update_user(user, update_attrs)
      assert user.username == "some updated username"
      assert user.password == "some updated password"
      assert user.email == "some updated email"
      assert user.birthdate == ~D[2025-06-22]
      assert user.firstname == "some updated firstname"
      assert user.lastname == "some updated lastname"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end

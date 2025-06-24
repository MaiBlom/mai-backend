defmodule Src.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Src.Users` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        birthdate: ~D[2025-06-21],
        email: "some email",
        firstname: "some firstname",
        lastname: "some lastname",
        password: "some password",
        username: "some username"
      })
      |> Src.Users.create_user()

    user
  end
end

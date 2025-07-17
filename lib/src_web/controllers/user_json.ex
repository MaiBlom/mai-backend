defmodule SrcWeb.UserJSON do
  alias Src.Users.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      username: user.username,
      password: user.password,
      email: user.email,
      birthdate: user.birthdate,
      firstname: user.firstname,
      lastname: user.lastname
    }
  end
end

defmodule Src.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Src.Repo
  alias Src.Users.User
  alias Helpers.Hash

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user("username")
      %User{}

      iex> get_user("username")
      ** (Ecto.NoResultsError)

  """
  def get_user_with_username(username) do
    Repo.one(from u in User, where: u.username == ^username)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    salt = :crypto.strong_rand_bytes(32)
    {:ok, password} = Hash.hash(salt, attrs["password"])

    salt = Base.encode16(salt)
    password = Base.encode64(password)

    password = salt <> password

    nattrs = %{
      password:   password,
      username:   attrs["username"],
      firstname:  attrs["firstname"],
      lastname:   attrs["lastname"],
      email:      attrs["email"],
      birthdate:  attrs["birthdate"]
    }

    try do
      %User{}
      |> User.changeset(nattrs)
      |> Repo.insert()
    rescue
      e in Ecto.ConstraintError -> {:error, e.constraint}
      _ -> {:error, "Unexpected error in schema"}
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Returns a status depending on whether
  or not the input password matches
  the password stores in the databased

  ## Examples

      iex> login(user, password)
      :ok

      iex> login(user, password)
      :error

  """
  def login(%User{} = user, input_password) do
    salt = :string.slice(user.password, 0, 64)
    {:ok, salt} = Base.decode16(salt)

    password = :string.slice(user.password, 64)

    {:ok, hashed_input_password} = Hash.hash(salt, input_password)
    hashed_input_password = Base.encode64(hashed_input_password)

    with true <- password == hashed_input_password do
      {:ok}
    else false ->
      {:error}
    end
  end
end

defmodule Src.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :password, :string
    field :email, :string
    field :birthdate, :date
    field :firstname, :string
    field :lastname, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password, :email, :birthdate, :firstname, :lastname])
    |> validate_required([:username, :password, :birthdate])
    # |> unique_constraint([:username, :email], name: :users_username_email_index)
    # |> unique_constraint(:username, name: :users_username_index)
    # |> unique_constraint(:email, name: :users_email_index)
  end
end

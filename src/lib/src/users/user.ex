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
  end
end

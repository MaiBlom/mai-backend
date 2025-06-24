defmodule Src.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :password, :string, null: false
      add :email, :string
      add :birthdate, :date, null: false
      add :firstname, :string
      add :lastname, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, :username)
    create unique_index(:users, :email)
  end
end

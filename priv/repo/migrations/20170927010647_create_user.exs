defmodule Myapp.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :password_digest, :string

      timestamps()
    end
    
    create unique_index(:users, [:email])
    create unique_index(:users, [:username])
  end
end

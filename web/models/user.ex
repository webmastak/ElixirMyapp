defmodule Myapp.User do
  use Myapp.Web, :model
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "users" do
    has_many :posts, Myapp.Post

    field :username, :string, unique: true
    field :email, :string, unique: true
    field :password_digest, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps() 
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email, :password, :password_confirmation])
    |> validate_required([:username, :email, :password, :password_confirmation])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 5, message: dgettext("errors", "Password must be at least 5 characters"))
    |> validate_confirmation(:password, message: dgettext("errors", "Password does not match"))
    |> unique_constraint(:email, message: dgettext("errors", "Email already taken"))
    |> unique_constraint(:username, message: dgettext("errors", "Username already taken"))
    |> hash_password
  end
  
  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      changeset
      |> put_change(:password_digest, hashpwsalt(password))
    else
      changeset
    end
  end
end

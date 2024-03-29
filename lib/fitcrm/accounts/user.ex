defmodule Fitcrm.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fitcrm.Accounts.User

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :type, :string
    field :name, :string
    field :sex, :string
    field :height, :float
    field :weight, :float
    field :age, :integer
    field :activity, :integer
    field :bmr, :float
    field :tdee, :float
    field :pcos, :string
    field :ir, :string
    field :veg, :boolean
    field :plantype, :string
    field :planlevel, :string
    field :sessions, {:map, :integer}, default: %{}
    field :ref_id, {:array, :integer}
    has_many :weeks, Fitcrm.Plan.Week

    timestamps()
  end

  def formchangeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:weight, :height, :age, :activity, :bmr, :sex, :plantype, :planlevel, :pcos, :ir, :veg])
    |> validate_required([:weight, :height, :age, :activity, :bmr, :sex, :plantype, :planlevel, :pcos, :ir, :veg])
  end



  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :ref_id, :name, :type, :weight, :height, :age, :activity, :bmr, :veg, :tdee, :sex, :password, :plantype, :planlevel, :pcos, :ir])
    |> validate_required([:email])
    |> unique_email
    |> cast_assoc(:weeks)
    |> validate_password(:password)
    |> put_pass_hash
  end

  def create_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :ref_id, :password, :name, :type, :weight, :height, :age, :activity, :bmr, :veg, :tdee, :sex, :plantype, :planlevel, :pcos, :ir])
    |> validate_required([:email, :password])
    |> unique_email
    |> cast_assoc(:weeks)
    |> validate_password(:password)
    |> put_pass_hash
  end

  defp unique_email(changeset) do
    validate_format(changeset, :email, ~r/@/)
    |> validate_length(:email, max: 254)
    |> unique_constraint(:email)
  end

  # In the function below, strong_password? just checks that the password
  # is at least 8 characters long.
  # See the documentation for NotQwerty123.PasswordStrength.strong_password?
  # for a more comprehensive password strength checker.
  defp validate_password(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, password ->
      case strong_password?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  # If you are using Argon2 or Pbkdf2, change Bcrypt to Argon2 or Pbkdf2
  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes:
      %{password: password}} = changeset) do
    change(changeset, Comeonin.Argon2.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset

  defp strong_password?(password) when byte_size(password) > 7 do
    {:ok, password}
  end

  defp strong_password?(_), do: {:error, "The password is too short"}
end

defmodule SrcWeb.UserController do
  use SrcWeb, :controller

  alias Src.Users
  alias Src.Users.User

  action_fallback SrcWeb.FallbackController

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Users.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/user/#{user}")
      |> render(:show, user: user)
    else {:error, constraint} ->
        with true <- constraint == "users_email_index" do
          send_resp(conn, 406, "Email address is already taken")
        end

        with true <- constraint == "users_username_index" do
          send_resp(conn, 406, "Username is already taken")
        end

        send_resp(conn, 406, "Unexpected error")
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    with {:ok, %User{}} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def login(conn, %{"user" => user_params}) do
    user = Users.get_user_with_username(user_params["username"])

    with {:ok} <- Users.login(user, user_params["password"]) do
      send_resp(conn, 202, "Logged in")
    else {:error} ->
      send_resp(conn, 401, "Incorrect login credentials")
    end
  end

  #def logout(conn, %{"user" => user_params}) do
  #  user = Users.get_user_with_username(user_params["username"])
  #
  #  with {:ok} <- Users.login(user, user_params["password"]) do
  #    send_resp(conn, 202, "Logged in")
  #  else {:error} ->
  #    send_resp(conn, 401, "Incorrect login credentials")
  #  end
  #end
end

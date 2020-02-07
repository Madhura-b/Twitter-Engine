defmodule TwitterwebappWeb.UserController do
  use TwitterwebappWeb, :controller

  def index(conn, _params) do
    render(conn, "newuser.html")
  end

  def create(conn, params) do
    IO.puts "The parameters are"
    IO.inspect params
    form_values_map = Map.get(params,"user")
    username = Map.get(form_values_map,"username")
    password = Map.get(form_values_map,"password")
    IO.puts "Username and password are "
    IO.inspect username
    IO.inspect password
    status = TwitterEngine.getRegistrationStatus(username)
    case status do
      true ->   conn
                |> put_session(username, 1)
                |> put_flash(:info, "Signed in successfully.")
                |> redirect( to: "/users/"<>username)
      false ->  TwitterEngine.registerUser(username,password)
                conn
                |> put_session(username, 1)
                |> put_flash(:info, "Logged in")
                |> redirect( to: "/users/"<>username)
              #  |> render("tweetspage.html", userid: username)
    end
#    TwitterEngine.registerUser(username,password)
#    conn
#    |> put_session(username, 1)
#    |> put_flash(:info, "Signed up successfully.")
  #  |> signed_in?()
    #|> render("tweetspage.html", userid: username)
#    |> redirect( to: "/users/"<>username)
  #  |> redirect(to: Routes.user_path(conn, :show, %{id: username}))
  end

  def signed_in(conn,id) do
    user_id = Plug.Conn.get_session(conn, id)
    status = case user_id do
                1 -> true
                :nil -> false
              end
    IO.puts "Status is"
    IO.inspect status
    status
  end


  def new(conn,_params) do
    IO.puts "Called here atleast"
    render(conn,"checknewuser.html")
  end

  def show(conn,%{"id" => id}) do
    case signed_in(conn,id) do
      true  -> IO.puts "#{id} is signed in"
               render(conn,"tweetspage.html", userid: id)
      false -> IO.puts "#{id} is NOT signed in "
               conn
               |> put_flash(:info, "You need to sign in first")
               |> render( "checknewuser.html")
    end
  end
end

defmodule ClientSupervisor do
  use Supervisor

  def start_link(users) do
    {:ok, pid} = Supervisor.start_link(__MODULE__,users,name: __MODULE__)
    #addNewTweet(pid,list)
    pid
  end



  @spec init(integer) :: {:ok, {map, [any]}}
  def init(users) do

    children = Enum.map(1..(users),fn (x) -> Supervisor.child_spec({Client,x},id: x) end)
    Supervisor.init(children, strategy: :one_for_one)

  end

  def testing(num_user,num_msg) do
    pid = ClientSupervisor.start_link(num_user)
  end

  def simulate(num_user,num_msg) do
      pid = ClientSupervisor.start_link(num_user)
      proc = Supervisor.which_children(pid)
      usernames = Enum.map(proc, fn (x) ->
                    {_,node,_,_} = x
                    username = GenServer.call(node,{:getUsername})
                  end)

      following_count = 5#Enum.random(1..(num_user))
      Task.async_stream(usernames,fn (user)->
                #Each user follows random usernames
                Task.async_stream(1..following_count, fn _ ->
                  IO.puts "Adding follower"
                  TwitterwebappWeb.Endpoint.broadcast! "room:registrations", "simulation", %{
                    response: "Adding follower"
                  }
                  new_following = Enum.random(usernames)
                  TwitterEngine.addFollowing(user,new_following)
                end)
                |> Enum.to_list()

              end)
      |> Enum.to_list()


      Enum.each(usernames, fn (user) ->
        TwitterEngine.getFollowing(user)
      end)

      msg_generator = Task.async_stream(1..num_msg, fn i ->
                        msg = "Tweet "<>Kernel.inspect(i)<>" from "
                        msg
                      end)
                      |> Enum.into([],fn {:ok,res} -> res end)

      user_msg_mapping = Task.async_stream(usernames, fn (user)->
                            msg_to_be_sent = Task.async_stream(msg_generator, fn (msg)->
                                                                msg<>Kernel.inspect(user)
                                                                end)
                                             |> Enum.into([],fn {:ok,res} -> res end)


                            {user,msg_to_be_sent}
                          end)
                         |> Enum.into(%{},fn {:ok,res} -> res end)



      #Each user sending out messages
      try do
            Task.async_stream(usernames, fn (user)->

                        to_send_list = Map.get(user_msg_mapping, user)
                        Task.async_stream(to_send_list, fn (msg)->
                               addNewTweetForSimulator(pid,user,msg,usernames)
                        end)
                        |> Enum.to_list()
            end)
            |> Enum.to_list()
       catch
         :exit, _ -> IO.puts "Messages sent to everyone !"
       after
      #   IO.puts "Done with simulation"
       end

       pid
  end

  def mapUserTopid(pid) do
    processes = Supervisor.which_children(pid)
    list =Enum.map(processes, fn (x) ->
      {_,node,_,_} = x
      username = GenServer.call(node,{:getUsername})
    #  IO.inspect [node,username]
      [node,username] end)
    list
  end

  def addNewTweetForSimulator(pid,user,msg,all_users) do

    list = mapUserTopid(pid)
    username_pid_map = Enum.map(list,fn (item)->
                          {Enum.at(item,1),Enum.at(item,0)}
                       end)
                       |> Map.new

    if (Enum.member?(all_users,user)==true) do
        userpid = Map.get(username_pid_map,user)
        GenServer.cast(userpid,{:addTweet,msg})
        GenServer.cast(userpid,{:sendNotificationToLiveNodes,user,list,msg})
    end

  end



  def addNewTweet(pid,user,msg) do
  #  user = IO.gets "Which user do you want to tweet as ? "
  #  IO.inspect user
  #  user = String.trim(user, "\n")
  #  IO.inspect user
    #Add functionality to check if user exists
    #Add functinoality to make user log in if he's not logged in already

    list = mapUserTopid(pid)

    proc = Supervisor.which_children(pid)
    Enum.each(proc, fn (x) ->
      {_,node,_,_} = x
      #IO.inspect (GenServer.call(node,{:getUsername}))
      username = GenServer.call(node,{:getUsername})
      IO.puts "username is "
      IO.inspect username
      cond do
        username == user && GenServer.call(node,{:getloginStatus}) ==1 ->
                        #    msg = IO.gets "Enter tweet msg"
                        #    msg = String.trim(msg,"\n")
                            GenServer.cast(node,{:addTweet,msg})
                            GenServer.cast(node,{:sendNotificationToLiveNodes,user,list,msg})
        true -> IO.puts "Username not  logged in "
      end
     end)
  end

  def login(pid)do
    username = IO.gets "Enter your username"
    username = String.trim(username, "\n")

    password = IO.gets "Enter your password "
    password = String.trim(password,"\n")
    result = TwitterEngine.loginUser(username,password)
    cond do
      result == 1 -> IO.puts "Login Successful"
                    GenServer.call(pid,{:updateLoginState,result})
      true-> IO.puts "Login Unsuccessful"
    end
  end


  def displayUsers(pid) do
    proc = Supervisor.which_children(pid)
    Enum.each(proc,
      fn (x) ->
            IO.inspect x
    end)
  end
end




defmodule Client do
  use GenServer

  def start_link(num) do
    GenServer.start_link(__MODULE__,num,[])
  end

  def init(num) do

  #  username = IO.gets "Enter preferred username"
  #  username = String.trim(username, "\n")

  #  password = IO.gets "Enter the password "
  #  password = String.trim(password,"\n")

  #  IO.puts "Username "
  #  IO.inspect username
  #  IO.puts "Created ! "
    TwitterEngine.registerUser(num,num)
    IO.puts "HIIIIIIIIIIIIIIIIIIIIIIIIIIIII"
    state = {num,1,[]}
  #  state= {username,1,[]}
    {:ok,state} #state = {username,loginstatus,livenotifications}
  end


  def addNewTweetForWebClient(userpid,msg) do

        GenServer.cast(userpid,{:addTweet,msg})
      #  GenServer.cast(userpid,{:sendNotificationToLiveNodes,user,list,msg})

  end
  def handle_call({:getUsername},_from,state) do
  #  IO.inspect "state is"
  #  IO.inspect state
    {username,_loginstatus,_livemsgs}=state
    {:reply,username,state}

  #  spawn fn ->
  #    {username,_loginstatus,_livemsgs}=state
  #    GenServer.reply(from,username)
  #  end

  #  {:noreply,state}
  end

  def handle_call({:getloginStatus},_from,state) do
    {_username,loginstatus,_}=state
    {:reply,loginstatus,state}
  end

  def handle_call({:printstate},_from,state) do
    {username,loginstatus,livemessage}=state
    {:reply,state,state}
  end

  def handle_call({:getlivenotificationlist},_from,state) do
    {_username,_loginstatus,livemessages} =  state
    {:reply,livemessages,state}
  end

  def handle_call({:setToOfflineMode},_from,state) do
    {username,_loginstatus,livenotifications} = state
    state={username,0,livenotifications}
    {:reply,state,state}
  end


  def handle_call({:updateLoginState,result},_from,state) do
    {username,_loginstatus,list}=state
    state={username,result,list}
    {:reply,result,state}
  end

  def handle_cast({:notifylivenode,msg},state) do
    {username,loginstatus,livemsgs}=state
    state = {username,loginstatus,[livemsgs]++[msg]}
  #  IO.inspect "Notification recieved"
  #  IO.inspect msg
    broadcastToChannel("Notif received"<>msg)
   {:noreply,state}
  end





  def handle_cast({:addTweet,msg},state) do

  #  IO.puts "Tweeting "
  #  IO.inspect msg

    broadcastToChannel("Tweeting "<>msg)

    {username,_,_}=state

    #If logged in
    TwitterEngine.storeTweet(username,msg)

    #if Not logged in, then make user login. Functionality to be added later.

    {:noreply,state}
  end

  def handle_cast({:sendNotificationToLiveNodes,user,list,msg},state) do
  #  IO.puts "Sending notification"
  #  IO.inspect msg
    broadcastToChannel("Sending notification "<>msg)
    #If logged in
  #  TwitterEngine.sendToLiveNode(user,list,msg)

    #if Not logged in, then make user login. Functionality to be added later.

    {:noreply,state}
  end



  def broadcastToChannel(resultset) do
    TwitterwebappWeb.Endpoint.broadcast "room:simulate", "simulate", %{response: resultset }



  end
end

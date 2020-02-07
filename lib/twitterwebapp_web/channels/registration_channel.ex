defmodule TwitterwebappWeb.RegistrationChannel do
  use TwitterwebappWeb, :channel
  alias TwitterwebappWeb.Router.Helpers, as: Routes

  def join("room:registrations", _params, socket) do
  #  {:ok, %{channel: channel_name}, socket}

     {:ok,socket}
  end

  def join("room:" <> var, _params, socket) do
    IO.puts "trying to join but failing"
    {:ok,  socket}
  #   {:ok,socket}
  end


  def handle_in("post_tweet",mapresult, socket) do
    IO.puts "Called Here"
    IO.inspect mapresult
    {username,_} = Integer.parse(Map.get(mapresult,"username"))

    IO.puts " Username is "
    IO.inspect username

    msg = Map.get(mapresult,"tweet_msg")
    IO.puts "Message to be posted is"
    IO.inspect msg

    {:ok,clientpid} = Client.start_link(username)
    IO.puts "Pid is"
    IO.inspect clientpid
    Client.addNewTweetForWebClient(clientpid,msg)
    broadcast!(socket, "listen_to_tweets", %{content: [msg]})
  #  push(socket,"listen_to_tweets", %{content: [msg]})
    #TwitterEngine.storeTweet(5,msg)

    {:noreply,socket}
  end

  def handle_in("retweet",mapresult, socket) do
    IO.puts "Called Here"
    IO.inspect mapresult
    {username,_} = Integer.parse(Map.get(mapresult,"username"))

    IO.puts " Username is "
    IO.inspect username

    retweet_msg = TwitterEngine.retweets(username)
    retweet_msg = retweet_msg<>" (Retweet)"
    broadcast!(socket, "listen_to_tweets", %{content: [retweet_msg]})
  #  push(socket,"listen_to_tweets", %{content: [msg]})
    #TwitterEngine.storeTweet(5,msg)

    {:noreply,socket}
  end

  def handle_in("get_tweet",mapresult, socket) do
    IO.puts "Called Here inside get tweets"
    IO.inspect mapresult
    {username,_} = Integer.parse(Map.get(mapresult,"username"))

    IO.puts " Username is "
    IO.inspect username

    result = TwitterEngine.getTweets(username)
    IO.puts "Got the messages as follows "
    IO.inspect result
  #  [{400, ["Janwdwde Doe", [], [], {{2019, 12, 12}, {18, 15, 59}}, 0, 400]}]
    msg_list = Enum.map(result, fn(item)->
                  {_,msg} = item
                  Enum.at(msg,0)
                end)
    IO.puts "Message list "
    IO.inspect msg_list
    push(socket,"get_all_tweets", %{content: msg_list})
    #TwitterEngine.storeTweet(5,msg)

    {:noreply,socket}
  end

  def handle_in("addFollowing",mapresult, socket) do
    IO.puts "Called Here inside get tweets"
    IO.inspect mapresult
    {user1,_} = Integer.parse(Map.get(mapresult,"user1"))
    {user2,_} = Integer.parse(Map.get(mapresult,"user2"))


    TwitterEngine.addFollowing(user1,user2)
    IO.puts "Addeed followers"





    {:noreply,socket}
  end

  def handle_in("searchMentions",mapresult, socket) do
    IO.puts "Called Here inside get tweets"
    IO.inspect mapresult
    {user,_} = Integer.parse(Map.get(mapresult,"username"))


    tweetlist = TwitterEngine.getMyMentions(user)
    IO.puts "Tweets that I am mentioned in"
    IO.inspect tweetlist
    push(socket,"get_hashtags", %{content: tweetlist})


    {:noreply,socket}
  end

  def handle_in("searchHashtag",mapresult, socket) do
    IO.puts "Called Here inside get tweets"
    IO.inspect mapresult
    hashtag = Map.get(mapresult,"hashtag")


    tweetlist = TwitterEngine.searchTweetsByHashtag(hashtag)
    IO.puts "Tweets containing this hashtag"
    IO.inspect tweetlist

    push(socket,"get_mentions", %{content: tweetlist})


    {:noreply,socket}
  end


  def handle_in("user:add", %{"message" => content}, socket) do
    IO.puts "Content is"
    IO.inspect content

    TwitterEngine.start_link(1)
    ClientSupervisor.simulate(50,10)

    response1 = TwitterwebappWeb.UserView.render("landingpage.html", %{content: content})
    response = Phoenix.View.render_to_string(TwitterwebappWeb.UserView,"landingpage.html", %{content: content})
    #response = TwitterwebappWeb.UserView.render( "sample.json", %{name: :desi})
    IO.puts "Response"
    IO.inspect response
    broadcast!(socket, "room:registrations:new_user", %{html: response,content: content})
    push(socket,"render_response", %{html: response, content: content})
#    response = socket
#               |>
#               Phoenix.View.render_one(TwitterwebappWeb.UserView, "sample.json", name: :desikan)

  #  socket
  #  |> Phoenix.Controller.redirect(to: Routes.user_path(TwitterwebappWeb, TwitterwebappWeb.UserView, content) )
  #  html = Phoenix.LiveView.render(TwitterwebappWeb.UserView,"landingpage.html",content)
  #  IO.puts "Landing page is"
  #  IO.inspect html

    {:reply, {:ok,%{}}, socket}
  end

  def handle_in("simulation",msg, socket) do
    IO.puts "Response value from genserver is"
    IO.inspect msg
    IO.puts "Done"

  #  response = Phoenix.View.render_to_string(TwitterwebappWeb.UserView,"landingpage.html", %{content: :random})
  #  push(socket,"render_response", %{html: response, content: msg})

    {:noreply, socket}
  end

  def handle_in("search_tweets",mapresult, socket) do
    username=String.to_integer(Enum.at(mapresult,0))
    searchmsg=(Enum.at(mapresult,1))
    IO.puts " Username is "
    IO.inspect username

    result = TwitterEngine.searchTweetsSubscribedTo(username,searchmsg)
    msg_list = Enum.map(result, fn(item)->
                list_item=Tuple.to_list(item)
                list_item
    end)
    IO.inspect(msg_list)
    IO.puts "Got the messages as follows >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    IO.inspect (List.flatten(msg_list))
    push(socket,"display_serached_tweets", %{content: [msg_list]})#List.flatten(msg_list) })
    {:noreply,socket}
  end

end

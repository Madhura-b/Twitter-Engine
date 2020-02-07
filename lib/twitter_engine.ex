defmodule TwitterEngine do
  use GenServer

  def start_link(_) do
    #{:ok,pid} = GenServer.start_link(__MODULE__,[])
    IO.puts "Engine is now running"
    #pid
    GenServer.start_link(__MODULE__,[])
  end

  def init(_) do
  # Create all ets tables
  #Registration table
  #User -> Password mapping



    IO.puts "Hi"

  #Tweets -> User mapping
    :ets.new(:registrations, [:set, :public, :named_table])

    #User -> Tweets he needs to see
    :ets.new(:users, [:bag, :public, :named_table])

    #User -> Following mapping
    :ets.new(:userfollowing, [:bag, :public, :named_table])

  #  :ets.new(:userfollowers, [:set, :public, :named_table])

    IO.puts "Created tables"
    {:ok,[]}
  end



  def registerUser(username, password) do
    :ets.insert(:registrations, {username,password})
    :ets.insert(:userfollowing, {username,username})
    IO.puts "Added"
  end

  def loginUser(username,password)do
    searchresultofusername = :ets.lookup(:registrations,username)
    #IO.inspect username
    #IO.inspect password
    #IO.inspect searchresultofusername
    cond do
      Enum.empty?(searchresultofusername)->0

      true -> [head|_tail] = searchresultofusername
              cond do
                elem(head,0) == username && elem(head,1) == password ->1
                true->0
              end
    end

  end





  def displayusers() do
    result = :ets.match_object(:registrations,{:'$1',:'$2'})
    #value = :ets.lookup(:registrations, "a")
    #userb = "b"
    #valueb = :ets.lookup(:registrations, userb)
    #IO.inspect result
    #IO.inspect valueb
  end

  def deleteUser(username) do
    :ets.delete(:registrations, username)
    :ets.delete(:users, username)
    :ets.delete(:userfollowing, username)
  end

  def getFollowers(username) do
    user_followers = :ets.match_object(:userfollowing, {:'$1',:'$2'})
        #  IO.puts "User followers list is as follows"
        #  IO.inspect user_followers

          user_followers_map = Enum.map(user_followers,
                                  fn (x) -> {key,_} = x
                                            values = Enum.map(user_followers,
                                                      fn(x)->
                                                        {newkey, value} = x;
                                                        if (newkey==key)
                                                        do
                                                          value
                                                        end
                                                      end)
                                                      |> Enum.reject(fn(x) -> x==:nil end)
                                             {key,values}
                                          end)
                                 |> Map.new

            users_list = Enum.map(user_followers, fn (user) -> {key,_} = user
                                                                key
                                  end)
                         |> Enum.uniq

            followers = Enum.map(users_list, fn (x)->
                          follows = Map.get(user_followers_map,x)
                          if Enum.member?(follows,username) == true
                          do
                              x
                          end
                        end)
                        |> Enum.reject(fn(x) -> x==:nil end)
                        |> Enum.reject(fn(x) -> x==username end)
      followers
  end



  def storeTweet(user,msg,retweet_ctr \\ 0) do

        hashtags =  Regex.scan(~r/#(\w*)/, msg)
                    |> Enum.map(fn(c) -> Enum.at(c,1) end)


        mentions =  Regex.scan(~r/@(\w*)/, msg)
                    |> Enum.map( fn(c) -> Enum.at(c,1) end)


        #Getalluserfollowers
        user_followers = :ets.match_object(:userfollowing, {:'$1',:'$2'})
    #    IO.puts "User followers list is as follows"
    #    IO.inspect user_followers

        user_followers_map = Enum.map(user_followers,
                                fn (x) -> {key,_} = x
                                          values = Enum.map(user_followers,
                                                    fn(x)->
                                                      {newkey, value} = x;
                                                      if (newkey==key)
                                                      do
                                                        value
                                                      end
                                                    end)
                                                    |> Enum.reject(fn(x) -> x==:nil end)
                                           {key,values}
                                        end)
                               |> Map.new

          users_list = Enum.map(user_followers, fn (user) -> {key,_} = user
                                                              key
                                end)
                       |> Enum.uniq

          followers = Enum.map(users_list, fn (x)->
                        follows = Map.get(user_followers_map,x)
                        if Enum.member?(follows,user) == true
                        do
                            x
                        end
                      end)
                      |> Enum.reject(fn(x) -> x==:nil end)

           current_time = :calendar.local_time()
           Enum.each(followers,fn(f)->
             :ets.insert(:users, {f,[msg,hashtags,mentions,current_time,retweet_ctr,user]})
           end)

           IO.puts "Done storing"
      end

      def sendToLiveNode(user,list,msg) do
        user_followers = :ets.match_object(:userfollowing, {:'$1',:'$2'})
        #  IO.puts "User followers list is as follows"
        #  IO.inspect user_followers

          user_followers_map = Enum.map(user_followers,
                                  fn (x) -> {key,_} = x
                                            values = Enum.map(user_followers,
                                                      fn(x)->
                                                        {newkey, value} = x;
                                                        if (newkey==key)
                                                        do
                                                          value
                                                        end
                                                      end)
                                                      |> Enum.reject(fn(x) -> x==:nil end)
                                             {key,values}
                                          end)
                                 |> Map.new

            users_list = Enum.map(user_followers, fn (user) -> {key,_} = user
                                                                key
                                  end)
                         |> Enum.uniq

            followers = Enum.map(users_list, fn (x)->
                          follows = Map.get(user_followers_map,x)
                          if Enum.member?(follows,user) == true
                          do
                              x
                          end
                        end)
                        |> Enum.reject(fn(x) -> x==:nil end)
                        |> Enum.reject(fn(x) -> x==user end)

      #  IO.inspect followers
        #if any of the followers are live, change their process state to include the message
       livenodepids =  Enum.map(followers,fn(follower)-> pids= Enum.map(list, fn(item_in_list)->
                                                                                                                #IO.inspect follower
                                                                                                                #IO.inspect item_in_list
                                                                                                                #IO.inspect Enum.at(item_in_list,1)
                                                                                                                #IO.inspect Enum.at(item_in_list,0)
                                                                                                              ids= cond do
                                                                                                               follower == Enum.at(item_in_list,1)-> id=  Enum.at(item_in_list,0)
                                                                                                                                                    id


                                                                                                               true-> []
                                                                                                                end
                                                                                                                ids
                                                                                        end )
                                                                                  #      IO.inspect pids


                                        end)
    #    IO.inspect livenodepids
    #    IO.puts "List of live nodes are"

        livepids = List.flatten(livenodepids)
    #    IO.inspect livepids

        Enum.each(livepids, fn(pid)->
                                  loginstatus =  GenServer.call(pid,{:getloginStatus})
                                      #    IO.inspect loginstatus
                                          cond do
                                            loginstatus == 1 -> GenServer.cast(pid, {:notifylivenode,msg})
                                                                #GenServer.call(pid,{:printstate})
                                            true->[]
                                          end
                                 end)
        #for every follower in the followers list
                  #retreive the pid-username mapping from the list
                      #get the loginstatus from the pid
                        #if login status is 1
                         #update the state to include the message

      end

  #this search is public. Can search tweets even if I'm not subscribed to it
  def searchTweetsByHashtag(hashtag) do
    result = :ets.match_object(:users, {:'$1',:'$2'})
    hashtag = String.slice(hashtag,1..-1)
    hashtag_tweets = Enum.map(result, fn (r)->
                        {_,tweet} = r
                        hashtags_list = Enum.at(tweet, 1)  #Gets the hashtag list for each result in the table
                        if (Enum.member?(hashtags_list,hashtag) == true)
                        do
                          Enum.at(tweet, 0)  #Return the tweet message, which is stored at 0
                        end
                     end)
                     |> Enum.uniq
                     |> Enum.reject(fn(x) -> x==:nil end)


      IO.puts "List of tweets contains that hashtag are : "
      IO.inspect hashtag_tweets
      hashtag_tweets
  end

  #this search is also public
  def getMyMentions(username) do
    result = :ets.match_object(:users, {:'$1',:'$2'})
    IO.puts "Result is "
    IO.inspect result
    my_mentions = Enum.map(result, fn (r)->
                    {_,tweet} = r
                    mentions_list = Enum.at(tweet, 2)   #Gets the mentions list for each result in the table
                    if (Enum.member?(mentions_list,to_string(username)) == true)
                    do
                      Enum.at(tweet, 0)   #Return the tweet message, which is stored at 0
                    end
                 end)
                 |> Enum.uniq
                 |> Enum.reject(fn(x) -> x==:nil end)

      IO.puts "List of my mentions are : "
      IO.inspect my_mentions
      my_mentions
  end

  #private search. Only querying my subscriber's tweets
  def searchTweetsSubscribedTo(username,search) do
    tweets = :ets.lookup(:users,username)
    tweet_msg = Enum.map(tweets, fn (t)->
                  {_,tweet_result} = t
                  Enum.at(tweet_result,0)
                end)

    IO.puts " Here are the list of messages relevant : "
    IO.inspect tweet_msg

    {:ok,regex_string} = Regex.compile(search)
    search_result = Enum.map(tweet_msg,fn (tweet)->


                      if (Regex.match?(regex_string,tweet) == true)
                        do
                        {
                          tweet
                        }
                      end
                    end)
                    |> Enum.reject (fn x -> x==:nil end)
    IO.puts "Here are the list of valid searches"
    IO.inspect search_result
    search_result
  end

  #public. Can retweet a random message
  def retweets(username) do
    result = :ets.match_object(:users, {:'$1',:'$2'})

    random_result = Enum.map(result, fn (r)->
                      {_,result} = r
                      result
                    end)
                    |> Enum.random
    tweet_msg = Enum.at(random_result,0)
    retweet_ctr = Enum.at(random_result,4)

    IO.puts "Retweeting the following message : "
    IO.inspect tweet_msg

    TwitterEngine.storeTweet(username, tweet_msg, retweet_ctr+1)
    tweet_msg
  end

  def addFollowing(user1,user2) do
    #Add functionality to add followers
    #IO.puts "User 1 is following user 2"
    :ets.insert(:userfollowing, {user1,user2})
  end

  def displayFollowingTable do
    records =:ets.match_object(:userfollowing,{:"$1",:"$2"})
    records
  end


  def getFollowing(user1) do
    result = :ets.match_object(:userfollowing,{user1,:_})
    following = Enum.map(result,fn(item)->
                                        {_,following_user}=item
                                        following_user

    end)
    following
  #  IO.inspect result
  end

  def simulate() do
    #random tweeting
    #random following
  end

  def getTweets(user) do
    value = :ets.lookup(:users,user)
    value
  end

  def getRegistrationStatus(user) do
    value = :ets.lookup(:registrations,user)
    status = cond do
                value==[] -> IO.puts "User not registered"
                             false
                true -> IO.puts "User registered"
                        true
              end
    status
  end


end

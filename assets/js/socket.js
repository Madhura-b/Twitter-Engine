// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect()



/*
// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("room:registrations", {})

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })
*/

if (document.querySelector("#simulate_process") !== null)
{
  let channel_simulate =socket.channel("room:simulate",{})

channel_simulate.join()
.receive("ok", resp => { console.log("Joined successfully simulate channel", resp) })
.receive("error", resp => { console.log("Unable to join simulate channel", resp) })


console.log(" Simulating ")
document.querySelector("#simulate_process").addEventListener('submit', (e) => {
    e.preventDefault()
    let totalusers = document.querySelector("#totalusers")
    let totalrequests = document.querySelector("#totalrequests")
    console.log(" Total Users : "+totalusers.value)

    channel_simulate.push('simulate', [totalusers.value,totalrequests.value])
  });


  channel_simulate.on("simulate", (message)=>{
    console.log("Recieving input from the GENSERVER YAAAY", message.response)
      let messageTemplate = `
        <h5>${message.response}</h5>
      `
      document.querySelector("#simulation_response").innerHTML += messageTemplate

    });
}

let channelID = window.channelRoomId;
if (channelID)
{
  console.log("trying to join channel "+`room:${channelID}`)
  let channel = socket.channel(`room:${channelID}`, {})
  channel.join()
    .receive("ok", resp => { console.log("Joined your own channel", resp) })
    .receive("error", resp => { console.log("Unable to join your own channel lol", resp) })



if (document.querySelector("#new_user_reg") !== null)
{
console.log(" The Elemt new_user_reg exists ")
document.querySelector("#new_user_reg").addEventListener('submit', (e) => {
    e.preventDefault()
    let username = document.querySelector("#username")
    console.log(" Username is "+username.value)
  //  let password = document.querySelector("#password").value;
    //let messageInput = e.target.querySelector('#message-content')

    channel.push('user:add', { message: username.value })

    //window.location.href = "http://localhost:4000/"

    //messageInput.value = ""
  });
}


if (document.querySelector("#post_tweet") !== null)
{
document.querySelector("#post_tweet").addEventListener('click', (e) => {
    e.preventDefault()
    console.log("Post tweet button was clicked")
    let msg = document.querySelector("#tweet_msg")
    console.log(" Message to be posted is "+msg.value)
    let channelRoomId = window.channelRoomId
    console.log(" Room ID is "+channelRoomId)
    channel.push("post_tweet", {tweet_msg: msg.value,username: channelRoomId})
    //let messageInput = e.target.querySelector('#message-content')

  //  channel.push('user:add', { message: username.value })

    //window.location.href = "http://localhost:4000/"

    //messageInput.value = ""
  });
}

if (document.querySelector("#get_tweets") !== null)
{

document.querySelector("#get_tweets").addEventListener('click', (e) => {
    e.preventDefault()
    console.log("Get All Tweets button was clicked")

    let channelRoomId = window.channelRoomId
    console.log(" Room ID is "+channelRoomId)
    channel.push("get_tweet", {username: channelRoomId})
  });
}

if (document.querySelector("#retweets") !== null)
{

document.querySelector("#retweets").addEventListener('click', (e) => {
    e.preventDefault()
    console.log("Get All Tweets button was clicked")
    let channelRoomId = window.channelRoomId
    console.log(" Room ID is "+channelRoomId)
    channel.push("retweet", {username: channelRoomId})
  });
}

if (document.querySelector("#search_tweets") !== null)
{

document.querySelector("#search_tweets").addEventListener('click', (e) => {
    e.preventDefault()
    console.log("Search Tweets button was clicked")

    let channelRoomId = window.channelRoomId
    let msg = document.querySelector("#search_msg")
    console.log(" We need to search for tweet "+msg.value)
    channel.push("search_tweets",[channelRoomId,msg.value])
  });
}

if (document.querySelector("#search_hashtags") !== null)
{

document.querySelector("#search_hashtags").addEventListener('click', (e) => {
    e.preventDefault()
    console.log("Search hashtags button was clicked")
    let msg = document.querySelector("#search_hashtag")
    console.log(" We need to search for hashtag "+msg.value)
    channel.push("searchHashtag", {hashtag: msg.value})
  });
}

if (document.querySelector("#search_mentions") !== null)
{

document.querySelector("#search_mentions").addEventListener('click', (e) => {
    e.preventDefault()
    console.log("Search mention button was clicked")
    let msg = document.querySelector("#search_mention")
    let channelRoomId = window.channelRoomId
    console.log(" We need to search for the mentions of user "+channelRoomId)
    channel.push("searchMentions", {username: channelRoomId})
  });
}

if (document.querySelector("#add_follower") !== null)
{

document.querySelector("#add_follower").addEventListener('click', (e) => {
    e.preventDefault()



    console.log("Need to add follower")
    let msg = document.querySelector("#follow")
    let channelRoomId = window.channelRoomId
    console.log(" user "+channelRoomId+" wants to follow "+msg.value)
    console.log("trying to join channel room:"+msg.value)
    let follow_channel = socket.channel(`room:${msg.value}`, {})
    follow_channel.join()
      .receive("ok", resp => { console.log("Joined your followers channel", resp) })
      .receive("error", resp => { console.log("Unable to join your followers channel lol", resp) })
    channel.push("addFollowing", {user2: msg.value,user1: channelRoomId})

    follow_channel.on("listen_to_tweets", (message) => {
        console.log("message", message)
        for (var i=0;i<message.content.length;i++)
        {
          let messageTemplate = `
            <li class="list-group-item">${message.content[i]}</li>
          `
          document.querySelector("#tweetslist").innerHTML += messageTemplate
        }

      });
  });
}



channel.on("room:registrations:new_user", (message) => {
    console.log("message", message.content)

    let messageTemplate = `
      <li class="list-group-item">${message.content}</li>
    `
    document.querySelector("#messageslist").innerHTML += messageTemplate
  });


/*  channel.on("listen_to_tweets", (message) => {
    console.log("message", message)


    let messageTemplate = `
      <li class="list-group-item">${message.content}</li>
    `
    document.querySelector("#tweetslist").innerHTML += messageTemplate

  });
*/
 /* channel.on("render_response", (message) => {
      console.log("message", message)
      document.querySelector("#maindiv").innerHTML = message.html

      let messageTemplate = `
        <li class="list-group-item">${message.content}</li>
      `
      document.querySelector("#messageslist").innerHTML += messageTemplate

    });*/


    channel.on("listen_to_tweets", (message) => {
        console.log("message", message)
        for (var i=0;i<message.content.length;i++)
        {
          let messageTemplate = `
            <li class="list-group-item">${message.content[i]}</li>
          `
          document.querySelector("#tweetslist").innerHTML += messageTemplate
        }
    });

    channel.on("get_tweet", (message) => {
      console.log("message", message)


      let messageTemplate = `
        <li class="list-group-item">${message.content}</li>
      `
      document.querySelector("#tweetslist").innerHTML += messageTemplate
    });


    channel.on("display_serached_tweets", (message) => {
      console.log("message", message)

      for (var i=0;i<message.content.length;i++)
      {

        let messageTemplate = `
          <li class="list-group-item">${message.content[i]}</li>
        `
        document.querySelector("#lists_response").innerHTML += messageTemplate

      }

    });


    /*channel.on("someone_is_tweeting",(message)=>{
      let channelRoomId = window.channelRoomId
      //console.log ("followers",message.following)
      let messageTemplate = `
        <li class="list-group-item">${message.tweet}</li>
      `
      message.followers.forEach(user => {if(channelRoomId == user)
      {
        console.log("Condition staisfied")
        document.querySelector("#lists_response").innerHTML += messageTemplate
      }})
    })*/


  channel.on("get_all_tweets", (message) => {
      console.log("message", message)
      document.querySelector("#tweetslist").innerHTML = ``
      for (var i=0;i<message.content.length;i++)
      {
        let messageTemplate = `
          <li class="list-group-item">${message.content[i]}</li>
        `
        document.querySelector("#tweetslist").innerHTML += messageTemplate
      }

    });

  channel.on("get_hashtags", (message) => {
      console.log("message", message)
      document.querySelector("#hashtaglist").innerHTML = ``
      for (var i=0;i<message.content.length;i++)
      {
        let messageTemplate = `
          <li class="list-group-item">${message.content[i]}</li>
        `
        document.querySelector("#hashtaglist").innerHTML += messageTemplate
      }

    });

    channel.on("get_mentions", (message) => {
        console.log("message", message)
        document.querySelector("#mentionslist").innerHTML = ``
        for (var i=0;i<message.content.length;i++)
        {
          let messageTemplate = `
            <li class="list-group-item">${message.content[i]}</li>
          `
          document.querySelector("#mentionslist").innerHTML += messageTemplate
        }

      });

}

export default socket

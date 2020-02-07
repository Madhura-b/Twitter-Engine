DOS Project - 4.2
Twitter Simulator with WebUI

Team Members : 
Madhura Basavaraju
Desikan Sundararajan 

How to Run

1) Run: mix phx.server
2) Navigate to http://localhost:4000/users/new

Link to the demo of the application: https://www.youtube.com/watch?v=BJemEEZr2w4
(Video also attached)

SignUp 
The user must sign up before he can enter the user page.
The username is required to be a number

User landing Page
http://localhost:4000/users/{username}   
eg: localhost:4000/users/5 for user 5

Simulation Page
localhost:4000/simulate


Implementation

Simulation:
The simulation page takes the number of clients and number of requests that must go out from every client as input from the user. The tweet messages are generated randomly and sent out from each user in a random manner. The input is passed to the backend code to simulate each client as a GenServer process that makes the given number of requests. As the simulation function is running , we output the details of the ongoing process such as which client is posting a tweet, the clients receiving the tweets and the clients receiving live notifications onto the console.


Authentication:

A user needs to be registered in order to access his landing page. After registering as a user, then the user needs to be logged in to access his page. We have implemented a session based authentication mechanism for the same. 

User Specific Functionalities:
Every user is initially assigned a channel of his own. As and when he subscribes to another user’s tweets, he joins the subscriber’s channel.
  In the user page the user can do the following: 

  Post a tweet
  Get tweets -  gets all tweets including those posted earlier
  
  Follow a user
  Search all tweets in the  feed based on an entered string
  
  Search for all tweets with a specific hashtag
  
  Get all the mentions of the user
  
  Retweet a tweet
  
  Live notifications of all incoming tweets in real time

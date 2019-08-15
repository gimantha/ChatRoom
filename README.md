# ChatRoom application

This project contain two modules.
  1. chat_service - Chat service which represents the chat room
  2. chat_client - chat client which is used to join the chat room and chat.

# Ballerina Chat Client

Please use the below command to start the chat client.

`$ballerina run chat_client.bal ws://<url>:<port>/chat ` 

Enter your username when asked and if the username is not already
registered you can join the chat room.

# Ballerina Chat Room

Please execute the following command to host the chat room.

`$ballerina run chat_service.bal` 

Above command will start a websocket based chat room on port 9090.

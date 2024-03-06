// const express = require('express');
// var http = require('http');
// const cors = require('cors');
// const app = express();
// var server = http.createServer(app);
// var io = require('socket.io')(server, {
//   cors: {
//     origin: '*',
//   }
// });

// io.on('connection', (socket) => {
//   console.log('A user connected:', socket.id);

//   socket.on('disconnect', () => {
//     console.log('User disconnected:', socket.id);
//   });

//   socket.on('message', (data) => {
//     console.log('Message received:', data);
//     io.emit('message', data); // Broadcast the message to all clients
//   });
// });

// const PORT = process.env.PORT || 3000;
// server.listen(PORT, () => {
//   console.log(`Server running on port ${PORT}`);
// });

const WebSocket = require("ws");

var webSockets = {};

const wss = new WebSocket.Server({ port: 5556 });

wss.on("connection", (ws,req) => {
  const username = req.url.split("/")[1];
 console.log(username + " connected");

  webSockets[username] = ws;
  ws.on("message", message => {
    console.log(message.toString())
    Object.values(webSockets).forEach(client => {
      client.send(message.toString());
    });
    var dataString = message.toString();
    dataString = dataString.replace(/\'/g, '"');
    var data = JSON.parse(dataString);

    console.log("Message received from client: " + data.message);
  });

  ws.on('close', function () {
    console.log(username + " disconnected");
    delete webSockets[username];
    console.log("User Disconnected: " + username);

  });
  ws.send("Hello! Message from server. You've just connected to the server!!");
});


// Imports
import express from 'express';
const app = express();
import cors from 'cors';
import {WebSocketServer } from 'ws';
import connectDB from './service/databaseService.js';
import { handleWebSocketConnection, handleWebSocketMessage, handleWebSocketDisconnection } from './controllers/websocketController.js';
import { getMessages, saveMessage, getMsg } from './controllers/messageController.js';
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { sendNotification } from './utils/notification.js';
import { createServer } from 'http';
import { Server } from 'socket.io';
const server = createServer(app);

const io = new Server(server);

// Firebase admin setup
initializeApp({
  credential: applicationDefault(),
  projectId: 'chatapp-7e54e',
});

// App Configuration

app.use(cors(
  {
    origin: '*',
    credentials: true
  }
));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/messages', getMessages);


io.on('connection', async (socket) => {
  console.log('a user connected', socket.handshake.query.username);

  // Handle WebSocket-like behavior
  // handleWebSocketConnection(socket);

  // Send existing messages to the newly connected client
  const messages = await getMsg();
  socket.emit('message', messages);

  // Handle incoming messages
  socket.on('message', async (message) => {
    console.log('Message received from client:', message);
    io.emit('message', message);

    // Perform any additional logic, such as sending notifications or saving messages to the database
    const { sender, message: msg } = message;
    if (sender === "sadhak") {
      sendNotification(sadhak, msg);
    } else {
      sendNotification(sadhak, msg);
    }
    
    // Store message in MongoDB
    await saveMessage(sender, msg);
  });

  // Handle disconnection
  socket.on('disconnect', () => {
    console.log('user disconnected'+ socket.handshake.query.username);
    // handleWebSocketDisconnection(socket.username);
  });
});



const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  connectDB();
  console.log(`Server running on port ${PORT}`);
});

// Tokens
const sadhak = "cTOHsqRPRmavjOyHFXTZ6S:APA91bGMc7CfSeuNHEGNwCLh-Rtu48gf0nDq4Vslns-Zz-p9xpASsFkLVleyf16poRoEXVD1Jj-fUjJg-1wdlwgWIE2toy9wMZZ0RsRwdARpcXo6s7qhnN1N20DQuPnipCZCkB5zQKhg"
const sadhak1 = "fMHfSO9lQ8-Kf3fZq2AIr9:APA91bGW7tKXhFugZJMcNzfD5Jd65Kg7H8P8hg3Hn1wHMK1VvjzN99P56JmjUOn7Pt6s3D5m9iAPql09cn1TRuWL2HRICsAZRKgg4OhKQnxdaDEkZNqUy-hhe7n7VgjTTGo07JyfqJqC"


// Sockets Configuration
// const wss = new WebSocketServer({ port: 5556 });

// wss.on('connection', async (ws, req) => {
//   handleWebSocketConnection(ws, req);

//   const messages = await getMsg();
//   ws.send(JSON.stringify(messages));

//   ws.on('message', async message => {
//     console.log(message.toString());

//     handleWebSocketMessage(message);

//     var dataString = message.toString();
//     dataString = dataString.replace(/\'/g, '"');
//     var data = JSON.parse(dataString);

//     console.log('Message received from client: ' + data.message);
//     if(data.sender === "sadhak"){
//       sendNotification(sadhak1,data.message)
//     }else{
//       sendNotification(sadhak,data.message)
//     }
    
//     // Store message in MongoDB
//     await saveMessage(data.sender, data.message);
//   });

//   ws.on('close', function () {
//     const username = req.url.split('/')[1];
//     handleWebSocketDisconnection(username);
//   });
// });


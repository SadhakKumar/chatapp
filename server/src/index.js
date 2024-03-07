// Imports
import express from 'express';
import cors from 'cors';
import {WebSocketServer } from 'ws';
import connectDB from './service/databaseService.js';
import { handleWebSocketConnection, handleWebSocketMessage, handleWebSocketDisconnection } from './controllers/websocketController.js';
import { getMessages, saveMessage, getMsg } from './controllers/messageController.js';
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';



// process.env.GOOGLE_APPLICATION_CREDENTIALS;
// Firebase admin setup
initializeApp({
  credential: applicationDefault(),
  projectId: 'chatapp-7e54e',
});

// App Configuration
const app = express();
app.use(cors(
  {
    origin: '*',
    credentials: true
  }
));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get("/", (req, res) => {
  res.send("Hello World!");
})
app.get('/messages', getMessages);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  connectDB();
  console.log(`Server running on port ${PORT}`);
});

// Tokens
const sadhak = "cTOHsqRPRmavjOyHFXTZ6S:APA91bGMc7CfSeuNHEGNwCLh-Rtu48gf0nDq4Vslns-Zz-p9xpASsFkLVleyf16poRoEXVD1Jj-fUjJg-1wdlwgWIE2toy9wMZZ0RsRwdARpcXo6s7qhnN1N20DQuPnipCZCkB5zQKhg"
const sadhak1 = "fMHfSO9lQ8-Kf3fZq2AIr9:APA91bGW7tKXhFugZJMcNzfD5Jd65Kg7H8P8hg3Hn1wHMK1VvjzN99P56JmjUOn7Pt6s3D5m9iAPql09cn1TRuWL2HRICsAZRKgg4OhKQnxdaDEkZNqUy-hhe7n7VgjTTGo07JyfqJqC"

// Function to send out notifications
const sendNotification = async (receiverToken,message) => {
  try {
    const messaging = {
      notification: {
        title: 'New Message',
        body: message
      },
      token: receiverToken,
    };
    const response = await getMessaging().send(messaging);
    console.log('Successfully sent notification:', response);
  } catch (error) {
    console.log('Error sending notification:', error);
  }
};



// Sockets Configuration

// const WebSocket = require("ws");
const wss = new WebSocketServer({ port: 5556 });

wss.on('connection', async (ws, req) => {
  handleWebSocketConnection(ws, req);

  const messages = await getMsg();
  ws.send(JSON.stringify(messages));

  ws.on('message', async message => {
    console.log(message.toString());

    handleWebSocketMessage(message);

    var dataString = message.toString();
    dataString = dataString.replace(/\'/g, '"');
    var data = JSON.parse(dataString);

    console.log('Message received from client: ' + data.message);
    if(data.sender === "sadhak"){
      sendNotification(sadhak1,data.message)
    }else{
      sendNotification(sadhak,data.message)
    }
    
    // Store message in MongoDB
    await saveMessage(data.sender, data.message);
  });

  ws.on('close', function () {
    const username = req.url.split('/')[1];
    handleWebSocketDisconnection(username);
  });
});


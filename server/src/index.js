import express from 'express';
import cors from 'cors';
import http from 'http';
import { Server } from 'socket.io';
import connectDB from './service/databaseService.js';

const messages = [];
const app = express();

app.use(cors({
  origin: "*",
  credentials: true

}));

const server = http.createServer(app);
const io = new Server(server);

app.get("/", (req, res) => {
  res.send("hello");
})

io.on('connection', (socket) => {
  const username = socket.handshake.query.username;
  socket.on('message', (data) => {
    const message = {
      message: data.message,
      username: username,
      sentAt: Date.now()
    }
    messages.push(message);
    socket.emit('message', message);  
  });
  console.log('a user connected');
});

server.listen(3000, () => {
  connectDB();
  console.log('listening on *:3000');
});
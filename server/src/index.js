// Imports
const express = require("express");
const app = express();
const cors = require("cors");
const connectDB = require("./service/databaseService");
const {getMessages} = require('./controllers/messageController');

// App Configuration
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


// Sockets Configuration
const WebSocket = require("ws");
const { handleWebSocketConnection, handleWebSocketMessage, handleWebSocketDisconnection } = require('./controllers/websocketController');
const { saveMessage,getMsg } = require('./controllers/messageController');

const wss = new WebSocket.Server({ port: 5556 });

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

    // Store message in MongoDB
    await saveMessage(data.sender, data.message);
  });

  ws.on('close', function () {
    const username = req.url.split('/')[1];
    handleWebSocketDisconnection(username);
  });
});


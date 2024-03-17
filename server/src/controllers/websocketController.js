// controllers/websocketController.js
const webSockets = {};

function handleWebSocketConnection(socket) {
  const username = req.url.split('/')[1];
  console.log(username + ' connected');
  webSockets[username] = ws;
}

function handleWebSocketMessage(message) {
  Object.values(webSockets).forEach(client => {
    client.send(message.toString());
  });
}

function handleWebSocketDisconnection(username) {
  console.log(username + ' disconnected');
  delete webSockets[username];
  console.log('User Disconnected: ' + username);
}

export{
    handleWebSocketConnection,
    handleWebSocketMessage,
    handleWebSocketDisconnection,
    };


// models/message.js
const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  sender: String,
  message: String,
  time: { type: Date, default: Date.now },
});

const Message = mongoose.model('Message', messageSchema);

module.exports = Message;

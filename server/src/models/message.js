// models/message.js
import mongoose from 'mongoose';

const messageSchema = new mongoose.Schema({
  sender: String,
  message: String,
  time: { type: Date, default: Date.now },
});

const Message = mongoose.model('Message', messageSchema);

export default Message;

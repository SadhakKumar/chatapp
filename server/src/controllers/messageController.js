// controllers/messageController.js
import Message from '../models/message.js';

const getMessages = async(req, res) => {
    try{
        const messages = await Message.find({}).exec();
        console.log(messages)
        res.status(200).json(messages); 
    }catch(e){
        console.error(e);
    }
}

async function getMsg() {
    return await Message.find({}).exec();
}

async function saveMessage(sender, message) {
  const newMessage = new Message({
    sender,
    message,
  });
  await newMessage.save();
}

export{
    getMessages,
    saveMessage,
    getMsg
}

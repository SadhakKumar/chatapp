import mongoose from "mongoose";

const connectDB = async () => {
  try {
    await mongoose.connect("mongodb+srv://sadhak2003:KFJzJo6i6w2UVuf2@cluster0.1ezq7ql.mongodb.net/", {
      useUnifiedTopology: true,
      useNewUrlParser: true,
    });
    console.log("MongoDB connection SUCCESS");
  } catch (error) {
    console.error("MongoDB connection FAIL", error);
    process.exit(1);
  }
};

export default connectDB;

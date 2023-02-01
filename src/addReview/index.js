const MongoClient = require("mongodb").MongoClient;

const ObjectId = require("mongodb").ObjectId;

//should be retrieved from AWS key management or another provider but due to
//this being a project I do not want to spend money on it is hardcoded.
const MONGODB_URI =
  "mongodb+srv://admin:admin@cluster0.adnpeqj.mongodb.net/?retryWrites=true&w=majority";

let cachedDb = null;

async function connectToDatabase() {
  if (cachedDb) {
    return cachedDb;
  }

  const client = await MongoClient.connect(MONGODB_URI);

  const db = await client.db("db");

  cachedDb = db;
  return db;
}

exports.handler = async (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;

  const db = await connectToDatabase();

  event = JSON.parse(event.body);
  const review = {
    User_name: event.User_name,
    Review: event.Review,
    Rating: event.Rating,
  };

  let responseBody;
  let statusCode;
  let message;
  let update;
  let id = new ObjectId(event.id);
  try {
    const query = { _id: id };
    update = { $push: { Reviews: review } };
    responseBody = await db.collection("Item").updateOne(query, update);

    message = "Successfully added to cart";
  } catch (error) {
    console.log("logging error: " + error);
    message = "Error adding review, please try again";
    responseBody = {};
  }

  const response = {
    statusCode: statusCode,
    headers: {
      "Access-Control-Allow-Headers": "Content-Type",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST",
    },
    body: JSON.stringify({
      message: message,
      response: responseBody,
    }),
  };

  return response;
};

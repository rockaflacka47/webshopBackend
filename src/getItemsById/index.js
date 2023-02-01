const MongoClient = require("mongodb").MongoClient;

//should be retrieved from AWS key management or another provider but due to
//this being a project I do not want to spend money on it is hardcoded.
const MONGODB_URI =
  "mongodb+srv://admin:admin@cluster0.adnpeqj.mongodb.net/?retryWrites=true&w=majority";

const ObjectId = require("mongodb").ObjectId;

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

  let responseBody = {};
  let statusCode = 404;
  let message = "Unable to retrieve cart items, please reload";
  event.Items.forEach((item) => {
    item.id = new ObjectId(item.id);
  });

  try {
    const query = { _id: { $in: event.Items } };
    responseBody = await db.collection("Item").find(query).toArray();
    statusCode = 200;
    message = "Success";
  } catch (error) {
    console.log(error);
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

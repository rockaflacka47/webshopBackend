const MongoClient = require("mongodb").MongoClient;

//should be retrieved from AWS key management or another provider but due to
//this being a project I do not want to spend money on it is hardcoded.
const MONGODB_URI = "mongodb+srv://admin:admin@cluster0.adnpeqj.mongodb.net/?retryWrites=true&w=majority";

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

  const count = await db.collection("Item").count();

  const response = {
    statusCode: 200,
     headers: {
            "Access-Control-Allow-Headers" : "Content-Type",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET"
        },
    body: JSON.stringify(count),
  };

  return response;
};
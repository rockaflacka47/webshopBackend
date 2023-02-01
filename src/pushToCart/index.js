const MongoClient = require("mongodb").MongoClient;

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
  const item = event.item;

  let responseBody;
  let statusCode;
  let message;
  let update;
  try {
    const query = { Email: event.Email };
    if (item.count === 0) {
      item.count = event.numToPush;
      update = { $push: { Cart: item } };
      responseBody = await db.collection("User").updateOne(query, update);
    } else {
      update = { $set: { "Cart.$[cart].count": event.numToPush + item.count } };
      const options = {
        arrayFilters: [
          {
            "cart.id": item.id,
          },
        ],
      };
      responseBody = await db
        .collection("User")
        .updateMany(query, update, options);
    }

    message = "Successfully added to cart";
  } catch (error) {
    console.log("logging error: " + error);
    message = "Error updating cart, please try again";
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

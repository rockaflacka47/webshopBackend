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
  let statusCode = 403;
  let message;
  let update;
  const finalCount = item.count - event.numToRemove;
  try {
    const query = { Email: event.Email };
    if (finalCount === 0) {
      const options = {
        arrayFilters: [
          {
            "cart.id": item.id,
          },
        ],
      };
      update = { $pull: { Cart: item } };
      responseBody = await db
        .collection("User")
        .updateOne(query, update, options);
    } else {
      update = { $set: { "Cart.$[cart].count": finalCount } };
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

    message = "Successfully removed from cart";
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

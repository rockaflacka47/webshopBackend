const connectToDatabase = require("../../common/db").connectToDatabase;

const ObjectId = require("mongodb").ObjectId;

exports.handler = async (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;

  const db = await connectToDatabase();

  event = JSON.parse(event.body);

  let message = "Could not find item with id: " + event.Id;
  let item = null;
  let statusCode = 404;
  try {
    const query = { _id: new ObjectId(event.Id) };
    item = await db.collection("Item").findOne(query);
    statusCode = "200";
    message = "Found Item";
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
      item: item,
      message: message,
    }),
  };

  return response;
};

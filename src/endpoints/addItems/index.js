const connectToDatabase = require("../../common/db").connectToDatabase;

exports.handler = async (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;

  const db = await connectToDatabase();

  event = event.body;
  let item;
  let statusCode = 502;
  let message = "Failed to add item, please try again or contact support.";
  try {
    item = await db.collection("Item").insertOne(event);
    statusCode = 200;
    message = "Successfully added item!";
  } catch (err) {
    console.log(err);
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
    }),
  };

  return response;
};

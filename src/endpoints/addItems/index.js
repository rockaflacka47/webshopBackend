const connectToDatabase = require("../../common/db").connectToDatabase;

const responseHeaders = require("../../common/headers").headers;

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
    headers: responseHeaders,
    body: JSON.stringify({
      message: message,
    }),
  };

  return response;
};

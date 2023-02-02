const connectToDatabase = require("../../common/db").connectToDatabase;
const responseHeaders = require("../../common/headers").headers;
const ObjectId = require("mongodb").ObjectId;

exports.handler = async (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;

  const db = await connectToDatabase();

  event = JSON.parse(event.body);

  let responseBody = {};
  let statusCode = 404;
  let message = "Unable to retrieve cart items, please reload";
  let ids = [];
  event.Items.forEach((item) => {
    ids.push(new ObjectId(item.id));
  });

  try {
    const query = { _id: { $in: ids } };
    responseBody = await db.collection("Item").find(query).toArray();
    statusCode = 200;
    message = "Success";
  } catch (error) {
    console.log(error);
  }

  const response = {
    statusCode: statusCode,
    headers: responseHeaders,
    body: JSON.stringify({
      message: message,
      response: responseBody,
    }),
  };

  return response;
};

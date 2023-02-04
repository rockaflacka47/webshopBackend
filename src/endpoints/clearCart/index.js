const connectToDatabase = require("../../common/db").connectToDatabase;

const responseHeaders = require("../../common/headers").headers;

exports.handler = async (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;

  const db = await connectToDatabase();
  console.log(event);
  event = JSON.parse(event.body);
  console.log(event);
  let user;
  let statusCode = 502;
  let message =
    "Failed to clear cart, please try removing items or contact support.";
  try {
    const query = { Email: event.Email };
    let update = { $set: { Cart: [] } };
    responseBody = await db.collection("User").updateOne(query, update);

    message = "Successfully cleared cart";
    statusCode = 200;
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

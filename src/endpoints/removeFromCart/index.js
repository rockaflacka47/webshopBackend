const connectToDatabase = require("../../common/db").connectToDatabase;

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
      responseBody = await db.collection("User").updateOne(query, update);
      statusCode = 200;
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
        .updateOne(query, update, options);
    }

    message = "Successfully removed from cart";
    statusCode = 200;
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

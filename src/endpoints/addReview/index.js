const connectToDatabase = require("../../common/db").connectToDatabase;

const ObjectId = require("mongodb").ObjectId;

exports.handler = async (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;

  const db = await connectToDatabase();

  event = JSON.parse(event.body);
  const review = {
    User_name: event.User_name,
    Review: event.Review,
    Rating: event.Rating,
  };

  let responseBody;
  let statusCode;
  let message;
  let update;
  let id = new ObjectId(event.id);
  try {
    const query = { _id: id };
    update = { $push: { Reviews: review } };
    responseBody = await db.collection("Item").updateOne(query, update);

    message = "Successfully added review";
  } catch (error) {
    console.log("logging error: " + error);
    message = "Error adding review, please try again";
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

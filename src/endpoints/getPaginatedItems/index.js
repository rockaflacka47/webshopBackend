const connectToDatabase = require("../../common/db").connectToDatabase;

const responseHeaders = require("../../common/headers").headers;

exports.handler = async (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;
  const db = await connectToDatabase();

  event = JSON.parse(event.body);

  let page = event.Page;

  let items = {};
  let statusCode = 500;
  let message = "Error retrieving items, please try again later";
  try {
    items = await db
      .collection("Item")
      .find({})
      .limit(12)
      .batchSize(12)
      .skip(page * 12)
      .toArray();
    statusCode = 200;
    message = "Successfully Retrieved page " + page;
  } catch (err) {
    console.log(err);
    //can trigger an alert here
  }

  const response = {
    statusCode: statusCode,
    headers: responseHeaders,
    body: JSON.stringify(items),
  };

  return response;
};

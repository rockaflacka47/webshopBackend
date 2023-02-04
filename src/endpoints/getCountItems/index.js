const connectToDatabase = require("../../common/db").connectToDatabase;
const responseHeaders = require("../../common/headers").headers;

exports.handler = async (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;

  const db = await connectToDatabase();

  console.log(responseHeaders);
  const count = await db.collection("Item").count();

  const response = {
    statusCode: 200,
    headers: responseHeaders,
    body: JSON.stringify(count),
  };

  return response;
};

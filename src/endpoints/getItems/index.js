const connectToDatabase = require("../../common/db").connectToDatabase;
const responseHeaders = require("../../common/headers").headers;
exports.handler = async (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;

  const db = await connectToDatabase();

  event = JSON.parse(event.body);

  let page = event.Page;

  console.log(page);

  const items = await db
    .collection("Item")
    .find({})
    .limit(12)
    .batchSize(12)
    .skip(page * 12)
    .toArray();

  const response = {
    statusCode: 200,
    headers: responseHeaders,
    body: JSON.stringify(items),
  };

  return response;
};

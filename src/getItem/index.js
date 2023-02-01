const MongoClient = require("mongodb").MongoClient;

//should be retrieved from AWS key management or another provider but due to
//this being a project I do not want to spend money on it is hardcoded.
const MONGODB_URI = "mongodb+srv://admin:admin@cluster0.adnpeqj.mongodb.net/?retryWrites=true&w=majority";

let cachedDb = null;

async function connectToDatabase() {
  if (cachedDb) {
    return cachedDb;
  }

  const client = await MongoClient.connect(MONGODB_URI);

  const db = await client.db("db");

  cachedDb = db;
  return db;
}

exports.handler = async (event, context) => {

  context.callbackWaitsForEmptyEventLoop = false;

  const db = await connectToDatabase();

  console.log(event);
  event = JSON.parse(event.body);

  let message = "Could not find item with id: " + event.Id;
  let item = {};
  let statusCode = 404;
  try{
    const query = { _id:  event.Id};
    item = await db.collection("Item").findOne(query);
    console.log(item);
    statusCode = "200";
    message="Found Item";
    
  } catch(error){
      console.log(error);
  }
  

  const response = {
    statusCode: statusCode,
    item: item,
    message: message
  };

  return response;
};
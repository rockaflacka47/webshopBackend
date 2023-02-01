const MongoClient = require("mongodb").MongoClient;

const PasswordHashGenerate = require("password-hash").generate;

const JwtSign = require("jsonwebtoken").sign;

//should be retrieved from AWS key management or another provider but due to
//this being a project I do not want to spend money on it is hardcoded.
const MONGODB_URI =
  "mongodb+srv://admin:admin@cluster0.adnpeqj.mongodb.net/?retryWrites=true&w=majority";

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

  event = JSON.parse(event.body);
  event.Password = PasswordHashGenerate(event.Password);
  let user;
  let statusCode;
  let message;
  let userId;
  let token;
  try {
    user = await db.collection("User").insertOne(event);
    statusCode = 200;
    message = "Successful";
    userId = user.insertedId;
    const query = { Email: event.Email };
    user = await db.collection("User").findOne(query);

    const email = user.Email;
    //should be retrieved from AWS key management or another provider but due to
    //this being a project I do not want to spend money on it is hardcoded.
    token = JwtSign(
      { Email: email, Password: event.Password },
      "tennis one two seven nine ball cat dog frisbee",
      {
        expiresIn: "2 days",
      }
    );
  } catch (error) {
    console.log("logging error: " + error);
    userId = -1;
    user = {};
    if (error.code === 11000) {
      statusCode = 409;
      message = "A user with that email already exists";
    }
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
      userId: userId,
      user: user,
      token: token,
    }),
  };

  return response;
};

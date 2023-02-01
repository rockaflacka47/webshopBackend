const MongoClient = require("mongodb").MongoClient;

const PasswordHashVerify = require("password-hash").verify;

const JwtSign = require("jsonwebtoken").sign;

const JwtVerify = require("jsonwebtoken").verify;

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

  let user;
  let statusCode;
  let message;
  let userId;
  let token;

  event = JSON.parse(event.body);
  if (event.Token) {
    //should be retrieved from AWS key management or another provider but due to
    //this being a project I do not want to spend money on it is hardcoded.
    tokenObj = JwtVerify(
      event.Token,
      "tennis one two seven nine ball cat dog frisbee"
    );
    console.log(tokenObj);
    const query = { Email: tokenObj.Email };
    user = await db.collection("User").findOne(query);
    statusCode = 200;
    message = "Successful";
    token = event.Token;
  } else {
    try {
      const query = { Email: event.Email };
      user = await db.collection("User").findOne(query);
      if (!user) {
        statusCode = 404;
        message = "No user exists with that email";
      } else {
        if (PasswordHashVerify(event.Password, user.Password)) {
          const email = user.Email;
          token = JwtSign(
            { Email: email, Password: event.Password },
            "tennis one two seven nine ball cat dog frisbee",
            {
              expiresIn: "2 days",
            }
          );
          message = "Successful";
          statusCode = 200;
        } else {
          message = "Incorrect email or password";
          statusCode = 401;
          user = {};
        }
      }
    } catch (error) {
      console.log("logging error: " + error);
      user = {};
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

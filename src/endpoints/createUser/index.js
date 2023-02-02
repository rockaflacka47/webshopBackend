const connectToDatabase = require("../../common/db").connectToDatabase;
require("dotenv").config();
const PasswordHashGenerate = require("password-hash").generate;

const JwtSign = require("jsonwebtoken").sign;

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
    token = JwtSign(
      { Email: email, Password: event.Password },
      process.env.SIGN_TOKEN,
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

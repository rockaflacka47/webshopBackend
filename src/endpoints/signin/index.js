const connectToDatabase = require("../../common/db").connectToDatabase;
require("dotenv").config();
const PasswordHashVerify = require("password-hash").verify;

const JwtSign = require("jsonwebtoken").sign;

const JwtVerify = require("jsonwebtoken").verify;

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
    try {
      const tokenObj = JwtVerify(event.Token, process.env.SIGN_TOKEN);

      const query = { Email: tokenObj.Email };
      user = await db.collection("User").findOne(query);
      statusCode = 200;
      message = "Successful";
      token = event.Token;
    } catch (error) {
      console.log("error: ");
      console.log(error);
      if (error.message === "jwt expired") {
        statusCode = 403;
        message = "Login expired, please login again";
        token = {};
      }
    }
  } else {
    try {
      const query = { Email: event.Email };
      user = await db.collection("User").findOne(query);
      if (!user) {
        statusCode = 404;
        message = "No user exists with that email";
      } else if (event.byEmailOnly) {
        message = "Successful";
        statusCode = 200;
      } else {
        if (PasswordHashVerify(event.Password, user.Password)) {
          const email = user.Email;
          token = JwtSign(
            { Email: email, Password: event.Password },
            process.env.SIGN_TOKEN,
            {
              expiresIn: "30 days",
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
